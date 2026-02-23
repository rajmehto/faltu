const jwt = require('jsonwebtoken');
const chatHandler = require('./chat.handler');
const giftHandler = require('./gift.handler');
const streamHandler = require('./stream.handler');
const notificationHandler = require('./notification.handler');
const logger = require('../utils/logger');

function setupSocketHandlers(io) {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      if (!token) {
        socket.user = null;
        return next();
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const User = require('../models/User');
      const user = await User.findOne({ userId: decoded.userId, isActive: true }).lean();
      socket.user = user;
      next();
    } catch (err) {
      socket.user = null;
      next();
    }
  });

  io.on('connection', (socket) => {
    logger.info(`Socket connected: ${socket.id} (user: ${socket.user?.userId || 'guest'})`);

    socket.on('ping', () => socket.emit('pong'));

    socket.on('stream:join', ({ streamId }) => {
      socket.join(`stream:${streamId}`);
      if (socket.user) {
        socket.to(`stream:${streamId}`).emit(`user:joined:${streamId}`, {
          userId: socket.user.userId,
          username: socket.user.username,
          displayName: socket.user.profile?.displayName,
          avatar: socket.user.profile?.avatar,
        });
      }
    });

    socket.on('stream:leave', ({ streamId }) => {
      socket.leave(`stream:${streamId}`);
      if (socket.user) {
        socket.to(`stream:${streamId}`).emit(`user:left:${streamId}`, {
          userId: socket.user.userId,
        });
      }
    });

    socket.on('room:join', ({ roomId }) => {
      socket.join(`room:${roomId}`);
    });

    socket.on('room:leave', ({ roomId }) => {
      socket.leave(`room:${roomId}`);
    });

    chatHandler(io, socket);
    giftHandler(io, socket);
    streamHandler(io, socket);
    notificationHandler(io, socket);

    socket.on('disconnect', (reason) => {
      logger.info(`Socket disconnected: ${socket.id} (${reason})`);
    });

    socket.on('error', (err) => {
      logger.error(`Socket error: ${socket.id}`, err);
    });
  });

  return io;
}

module.exports = { setupSocketHandlers };
