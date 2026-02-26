const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const giftController = require('../controllers/gift.controller');

router.get('/', optionalAuth, giftController.getGifts);
router.post('/send', authenticate, giftController.sendGift);
router.get('/leaderboard', optionalAuth, giftController.getGiftLeaderboard);
router.get('/history', authenticate, giftController.getGiftHistory);

module.exports = router;
