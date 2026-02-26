const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/auth.middleware');
const analyticsController = require('../controllers/analytics.controller');

router.get('/dashboard', authenticate, analyticsController.getStreamerDashboard);
router.get('/stream/:streamId', authenticate, analyticsController.getStreamAnalytics);
router.get('/earnings', authenticate, analyticsController.getEarningsReport);

module.exports = router;
