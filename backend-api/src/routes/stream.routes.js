const express = require('express');
const router = express.Router();
const { body, query } = require('express-validator');

const streamController = require('../controllers/stream.controller');
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const { streamRateLimit } = require('../middlewares/rateLimit.middleware');
const { validateRequest } = require('../middlewares/validation.middleware');

router.post('/start',
  authenticate,
  streamRateLimit,
  [
    body('title').notEmpty().trim().isLength({ max: 80 }),
    body('category').notEmpty(),
    body('privacy').optional().isIn(['public', 'private', 'followers_only', 'password_protected']),
  ],
  validateRequest,
  streamController.startStream
);

router.post('/end', authenticate, streamController.endStream);

router.get('/live', optionalAuth, streamController.getLiveStreams);
router.get('/trending', optionalAuth, streamController.getTrendingStreams);
router.get('/nearby', optionalAuth, streamController.getNearbyStreams);
router.get('/recommended', optionalAuth, streamController.getRecommendedStreams);
router.get('/search', optionalAuth, streamController.searchStreams);
router.post('/schedule', authenticate, streamController.scheduleStream);

router.get('/:streamId', optionalAuth, streamController.getStream);
router.post('/:streamId/join', optionalAuth, streamController.joinStream);
router.post('/:streamId/leave', optionalAuth, streamController.leaveStream);
router.post('/:streamId/like', authenticate, streamController.likeStream);
router.post('/:streamId/share', authenticate, streamController.shareStream);
router.post('/:streamId/report', authenticate, streamController.reportStream);
router.post('/:streamId/cohost', authenticate, streamController.addCoHost);
router.delete('/:streamId/cohost', authenticate, streamController.removeCoHost);
router.post('/:streamId/record', authenticate, streamController.startRecording);
router.post('/:streamId/stop-record', authenticate, streamController.stopRecording);
router.post('/:streamId/moderate', authenticate, streamController.moderateUser);

module.exports = router;
