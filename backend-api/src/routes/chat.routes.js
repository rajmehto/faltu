const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const chatController = require('../controllers/chat.controller');

router.get('/dm', authenticate, chatController.getDMList);
router.get('/dm/:userId', authenticate, chatController.getDirectMessages);
router.post('/dm/:userId', authenticate, chatController.sendDirectMessage);
router.get('/stream/:streamId/messages', optionalAuth, chatController.getStreamMessages);
router.post('/stream/:streamId/messages', authenticate, chatController.sendMessage);
router.delete('/messages/:messageId', authenticate, chatController.deleteMessage);
router.put('/messages/:messageId/pin', authenticate, chatController.pinMessage);
router.post('/messages/:messageId/reactions', authenticate, chatController.addReaction);

module.exports = router;
