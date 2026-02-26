const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/auth.middleware');
const paymentController = require('../controllers/payment.controller');

router.get('/packages', authenticate, (req, res) => {
  res.redirect('/api/v1/wallet/packages');
});
router.post('/stripe/intent', authenticate, paymentController.createStripeIntent);
router.post('/razorpay/order', authenticate, paymentController.createRazorpayOrder);
router.post('/stripe/webhook', express.raw({ type: 'application/json' }), paymentController.stripeWebhook);
router.post('/razorpay/webhook', paymentController.razorpayWebhook);
router.post('/verify', authenticate, paymentController.verifyAndCreditCoins);

module.exports = router;
