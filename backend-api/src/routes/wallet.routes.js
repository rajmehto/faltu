const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/auth.middleware');
const walletController = require('../controllers/wallet.controller');

router.get('/', authenticate, walletController.getWallet);
router.get('/packages', authenticate, walletController.getCoinPackages);
router.get('/transactions', authenticate, walletController.getTransactionHistory);
router.post('/withdraw', authenticate, walletController.requestWithdrawal);
router.get('/withdrawals', authenticate, walletController.getWithdrawalHistory);

module.exports = router;
