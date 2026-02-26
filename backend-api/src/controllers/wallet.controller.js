const User = require('../models/User');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');
const { getPostgresPool } = require('../config/database');

exports.getWallet = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id).select('wallet username profile.displayName').lean();

    res.json({ success: true, data: user.wallet });
  } catch (error) {
    next(error);
  }
};

exports.getCoinPackages = async (req, res, next) => {
  try {
    const packages = [
      { id: 'pkg_100', coins: 100, price: 0.99, currency: 'USD', bonus: 0, popular: false },
      { id: 'pkg_500', coins: 500, price: 4.99, currency: 'USD', bonus: 0, popular: false },
      { id: 'pkg_1000', coins: 1000, price: 9.99, currency: 'USD', bonus: 100, popular: true },
      { id: 'pkg_2500', coins: 2500, price: 24.99, currency: 'USD', bonus: 300, popular: false },
      { id: 'pkg_5000', coins: 5000, price: 49.99, currency: 'USD', bonus: 800, popular: false },
      { id: 'pkg_10000', coins: 10000, price: 99.99, currency: 'USD', bonus: 2000, popular: false },
    ];

    res.json({ success: true, data: packages });
  } catch (error) {
    next(error);
  }
};

exports.getTransactionHistory = async (req, res, next) => {
  try {
    const pool = getPostgresPool();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const offset = (page - 1) * limit;
    const { type } = req.query;

    let whereClause = 'WHERE user_id = $1';
    const params = [req.user.userId];

    if (type) {
      params.push(type);
      whereClause += ` AND transaction_type = $${params.length}`;
    }

    const [rows, countResult] = await Promise.all([
      pool.query(
        `SELECT * FROM wallet_transactions ${whereClause} ORDER BY created_at DESC LIMIT $${params.length + 1} OFFSET $${params.length + 2}`,
        [...params, limit, offset]
      ),
      pool.query(
        `SELECT COUNT(*) FROM wallet_transactions ${whereClause}`,
        params
      ),
    ]);

    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      data: rows.rows,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.requestWithdrawal = async (req, res, next) => {
  try {
    const { amount, method, accountDetails } = req.body;

    if (!amount || amount < 100) {
      return res.status(400).json({ success: false, message: 'Minimum withdrawal amount is 100 diamonds' });
    }

    const user = await User.findById(req.user._id);
    if (user.wallet.diamonds < amount) {
      return res.status(400).json({ success: false, message: 'Insufficient diamonds' });
    }

    const validMethods = ['paypal', 'bank_transfer', 'stripe', 'razorpay'];
    if (!validMethods.includes(method)) {
      return res.status(400).json({ success: false, message: 'Invalid withdrawal method' });
    }

    const pool = getPostgresPool();
    const withdrawalId = uuidv4();

    const usdAmount = (amount * 0.005).toFixed(2);

    await pool.query(
      `INSERT INTO withdrawals (withdrawal_id, user_id, diamonds_amount, usd_amount, method, account_details, status, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, 'pending', NOW())`,
      [withdrawalId, req.user.userId, amount, usdAmount, method, JSON.stringify(accountDetails)]
    );

    await User.findByIdAndUpdate(req.user._id, {
      $inc: { 'wallet.diamonds': -amount },
    });

    res.status(201).json({
      success: true,
      data: { withdrawalId, amount, usdAmount, status: 'pending' },
      message: 'Withdrawal request submitted. Processing within 3-5 business days.',
    });
  } catch (error) {
    next(error);
  }
};

exports.getWithdrawalHistory = async (req, res, next) => {
  try {
    const pool = getPostgresPool();
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const [rows, countResult] = await Promise.all([
      pool.query(
        'SELECT * FROM withdrawals WHERE user_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3',
        [req.user.userId, limit, offset]
      ),
      pool.query('SELECT COUNT(*) FROM withdrawals WHERE user_id = $1', [req.user.userId]),
    ]);

    const total = parseInt(countResult.rows[0].count);

    res.json({
      success: true,
      data: rows.rows,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};
