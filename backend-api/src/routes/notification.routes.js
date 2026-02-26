const express = require('express');
const router = express.Router();
const { authenticate } = require('../middlewares/auth.middleware');
const notificationController = require('../controllers/notification.controller');

router.get('/', authenticate, notificationController.getNotifications);
router.get('/unread-count', authenticate, notificationController.getUnreadCount);
router.put('/read-all', authenticate, notificationController.markAllAsRead);
router.delete('/clear-all', authenticate, notificationController.clearAll);
router.put('/:notificationId/read', authenticate, notificationController.markAsRead);
router.delete('/:notificationId', authenticate, notificationController.deleteNotification);

module.exports = router;
