const User = require('../models/User');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');
const { getPostgresPool } = require('../config/database');

const COIN_PACKAGES = {
  pkg_100: { coins: 100, price: 99, currency: 'usd' },
  pkg_500: { coins: 500, price: 499, currency: 'usd' },
  pkg_1000: { coins: 1100, price: 999, currency: 'usd' },
  pkg_2500: { coins: 2800, price: 2499, currency: 'usd' },
  pkg_5000: { coins: 5800, price: 4999, currency: 'usd' },
  pkg_10000: { coins: 12000, price: 9999, currency: 'usd' },
};

exports.createStripeIntent = async (req, res, next) => {
  try {
    const { packageId } = req.body;

    const pkg = COIN_PACKAGES[packageId];
    if (!pkg) {
      return res.status(400).json({ success: false, message: 'Invalid package' });
    }

    if (!process.env.STRIPE_SECRET_KEY) {
      return res.status(503).json({ success: false, message: 'Payment service unavailable' });
    }

    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

    const paymentIntent = await stripe.paymentIntents.create({
      amount: pkg.price,
      currency: pkg.currency,
      metadata: {
        userId: req.user.userId,
        packageId,
        coins: pkg.coins.toString(),
      },
    });

    res.json({
      success: true,
      data: {
        clientSecret: paymentIntent.client_secret,
        paymentIntentId: paymentIntent.id,
        amount: pkg.price,
        currency: pkg.currency,
        coins: pkg.coins,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.createRazorpayOrder = async (req, res, next) => {
  try {
    const { packageId } = req.body;

    const pkg = COIN_PACKAGES[packageId];
    if (!pkg) {
      return res.status(400).json({ success: false, message: 'Invalid package' });
    }

    if (!process.env.RAZORPAY_KEY_ID || !process.env.RAZORPAY_KEY_SECRET) {
      return res.status(503).json({ success: false, message: 'Payment service unavailable' });
    }

    const Razorpay = require('razorpay');
    const razorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });

    const inrAmount = Math.round(pkg.price * 0.83);

    const order = await razorpay.orders.create({
      amount: inrAmount * 100,
      currency: 'INR',
      notes: {
        userId: req.user.userId,
        packageId,
        coins: pkg.coins.toString(),
      },
    });

    res.json({
      success: true,
      data: {
        orderId: order.id,
        amount: order.amount,
        currency: order.currency,
        keyId: process.env.RAZORPAY_KEY_ID,
        coins: pkg.coins,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.stripeWebhook = async (req, res, next) => {
  try {
    const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);
    const sig = req.headers['stripe-signature'];

    let event;
    try {
      event = stripe.webhooks.constructEvent(req.body, sig, process.env.STRIPE_WEBHOOK_SECRET);
    } catch (err) {
      return res.status(400).json({ success: false, message: `Webhook Error: ${err.message}` });
    }

    if (event.type === 'payment_intent.succeeded') {
      const paymentIntent = event.data.object;
      const { userId, packageId, coins } = paymentIntent.metadata;

      await creditCoins(userId, packageId, parseInt(coins), paymentIntent.id, 'stripe', paymentIntent.amount / 100);
    }

    res.json({ received: true });
  } catch (error) {
    next(error);
  }
};

exports.razorpayWebhook = async (req, res, next) => {
  try {
    const crypto = require('crypto');
    const body = req.body.payload?.payment?.entity;

    if (!body) return res.json({ received: true });

    const signature = req.headers['x-razorpay-signature'];
    const expectedSignature = crypto
      .createHmac('sha256', process.env.RAZORPAY_WEBHOOK_SECRET)
      .update(JSON.stringify(req.body))
      .digest('hex');

    if (signature !== expectedSignature) {
      return res.status(400).json({ success: false, message: 'Invalid signature' });
    }

    if (req.body.event === 'payment.captured') {
      const { userId, packageId, coins } = body.notes;
      await creditCoins(userId, packageId, parseInt(coins), body.id, 'razorpay', body.amount / 100);
    }

    res.json({ received: true });
  } catch (error) {
    next(error);
  }
};

exports.verifyAndCreditCoins = async (req, res, next) => {
  try {
    const { paymentId, packageId, provider } = req.body;

    const pkg = COIN_PACKAGES[packageId];
    if (!pkg) {
      return res.status(400).json({ success: false, message: 'Invalid package' });
    }

    const pool = getPostgresPool();
    const existing = await pool.query(
      'SELECT * FROM wallet_transactions WHERE reference_id = $1',
      [paymentId]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({ success: false, message: 'Payment already processed' });
    }

    await creditCoins(req.user.userId, packageId, pkg.coins, paymentId, provider, pkg.price / 100);

    const user = await User.findOne({ userId: req.user.userId }).select('wallet').lean();

    res.json({
      success: true,
      data: { coins: pkg.coins, wallet: user.wallet },
      message: `${pkg.coins} coins added to your wallet`,
    });
  } catch (error) {
    next(error);
  }
};

async function creditCoins(userId, packageId, coins, paymentId, provider, usdAmount) {
  const pool = getPostgresPool();
  const txId = uuidv4();

  await User.findOneAndUpdate(
    { userId },
    { $inc: { 'wallet.coins': coins } }
  );

  await pool.query(
    `INSERT INTO wallet_transactions (transaction_id, user_id, transaction_type, amount, currency, reference_id, provider, status, metadata, created_at)
     VALUES ($1, $2, 'coin_purchase', $3, 'coins', $4, $5, 'completed', $6, NOW())`,
    [txId, userId, coins, paymentId, provider, JSON.stringify({ packageId, usdAmount })]
  );
}
