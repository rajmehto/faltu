const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const roomController = require('../controllers/room.controller');

router.get('/', optionalAuth, roomController.getRooms);
router.post('/', authenticate, roomController.createRoom);
router.get('/:roomId', optionalAuth, roomController.getRoom);
router.post('/:roomId/join', authenticate, roomController.joinRoom);
router.post('/:roomId/leave', authenticate, roomController.leaveRoom);
router.post('/:roomId/end', authenticate, roomController.endRoom);
router.post('/:roomId/speaker', authenticate, roomController.requestSpeaker);

module.exports = router;
