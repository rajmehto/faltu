const Notification = require('../models/Notification');
const logger = require('../utils/logger');

module.exports = function (io, socket) {
  if (socket.user) {
    socket.join(`user:${socket.user.userId}`);

    Notification.countDocuments({
      recipientId: socket.user._id,
      isRead: false,
    })
      .then(count => {
        socket.emit('notification:unread_count', { count });
      })
      .catch(err => logger.error('notification unread count error', err));
  }

  socket.on('notification:read', async ({ notificationId }) => {
    if (!socket.user) return;

    try {
      await Notification.findOneAndUpdate(
        { _id: notificationId, recipientId: socket.user._id },
        { $set: { isRead: true, readAt: new Date() } }
      );

      const count = await Notification.countDocuments({
        recipientId: socket.user._id,
        isRead: false,
      });

      socket.emit('notification:unread_count', { count });
    } catch (err) {
      logger.error('notification:read error', err);
    }
  });

  socket.on('notification:read_all', async () => {
    if (!socket.user) return;

    try {
      await Notification.updateMany(
        { recipientId: socket.user._id, isRead: false },
        { $set: { isRead: true, readAt: new Date() } }
      );

      socket.emit('notification:unread_count', { count: 0 });
    } catch (err) {
      logger.error('notification:read_all error', err);
    }
  });
};

async function sendNotification(io, recipientUserId, notification) {
  io.to(`user:${recipientUserId}`).emit('notification:new', notification);
}

module.exports.sendNotification = sendNotification;
