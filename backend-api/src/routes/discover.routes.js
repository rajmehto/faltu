const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const discoverController = require('../controllers/discover.controller');

router.get('/live', optionalAuth, discoverController.getLiveStreams);
router.get('/trending', optionalAuth, discoverController.getTrendingStreams);
router.get('/categories', optionalAuth, discoverController.getCategories);
router.get('/search', optionalAuth, discoverController.search);
router.get('/nearby', optionalAuth, discoverController.getNearbyStreams);
router.get('/following', optionalAuth, discoverController.getFollowingStreams);
router.get('/recommended', optionalAuth, discoverController.getRecommended);

module.exports = router;
