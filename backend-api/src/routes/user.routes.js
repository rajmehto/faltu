const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const userController = require('../controllers/user.controller');

router.get('/suggestions', authenticate, userController.getSuggestions);
router.get('/search', optionalAuth, userController.searchUsers);
router.get('/blocked', authenticate, userController.getBlockedUsers);
router.get('/:userId', optionalAuth, userController.getProfile);
router.get('/:userId/followers', optionalAuth, userController.getFollowers);
router.get('/:userId/following', optionalAuth, userController.getFollowing);
router.get('/:userId/streams', optionalAuth, userController.getUserStreams);
router.put('/me/profile', authenticate, userController.updateProfile);
router.put('/me/settings', authenticate, userController.updateSettings);
router.put('/me/fcm-token', authenticate, userController.updateFcmToken);
router.delete('/me/account', authenticate, userController.deleteAccount);
router.post('/:userId/follow', authenticate, userController.followUser);
router.delete('/:userId/follow', authenticate, userController.unfollowUser);
router.post('/:userId/block', authenticate, userController.blockUser);
router.delete('/:userId/block', authenticate, userController.unblockUser);

module.exports = router;
