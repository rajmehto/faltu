const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const achievementController = require('../controllers/achievement.controller');

router.get('/', optionalAuth, achievementController.getAllAchievements);
router.get('/me', authenticate, achievementController.getMyAchievements);
router.get('/leaderboard', optionalAuth, achievementController.getLeaderboard);
router.get('/user/:userId', optionalAuth, achievementController.getUserAchievements);

module.exports = router;
