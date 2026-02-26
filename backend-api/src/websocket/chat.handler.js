const ChatMessage = require('../models/ChatMessage');
const Stream = require('../models/Stream');
const logger = require('../utils/logger');

module.exports = function (io, socket) {
  socket.on('chat:message', async (data) => {
    try {
      const { streamId, content, type = 'text', replyTo, imageUrl, stickerUrl } = data;

      if (!socket.user) {
        return socket.emit('chat:error', { message: 'Authentication required' });
      }

      if (!content || content.trim().length === 0) {
        return socket.emit('chat:error', { message: 'Empty message' });
      }

      const stream = await Stream.findOne({ streamId, status: 'live' }).lean();
      if (!stream) {
        return socket.emit('chat:error', { message: 'Stream not found or not live' });
      }

      if (stream.blockedUsers?.some(id => id.toString() === socket.user._id.toString())) {
        return socket.emit('chat:error', { message: 'You are blocked from this stream' });
      }

      const message = await ChatMessage.create({
        streamId,
        senderId: socket.user._id,
        senderUsername: socket.user.username,
        senderDisplayName: socket.user.profile?.displayName,
        senderAvatar: socket.user.profile?.avatar,
        senderLevel: socket.user.profile?.level || 1,
        type,
        content: content.trim().substring(0, 500),
        replyTo,
        imageUrl,
        stickerUrl,
      });

      io.to(`stream:${streamId}`).emit(`chat:message:${streamId}`, message);

      await Stream.findOneAndUpdate({ streamId }, { $inc: { 'stats.comments': 1 } });
    } catch (err) {
      logger.error('chat:message error', err);
      socket.emit('chat:error', { message: 'Failed to send message' });
    }
  });

  socket.on('chat:dm', async (data) => {
    try {
      const { toUserId, content, type = 'text' } = data;

      if (!socket.user) {
        return socket.emit('chat:error', { message: 'Authentication required' });
      }

      const User = require('../models/User');
      const targetUser = await User.findOne({ userId: toUserId, isActive: true }).lean();
      if (!targetUser) return;

      const dmRoomId = [socket.user._id.toString(), targetUser._id.toString()].sort().join(':');

      const message = await ChatMessage.create({
        roomId: dmRoomId,
        streamId: `dm:${dmRoomId}`,
        senderId: socket.user._id,
        senderUsername: socket.user.username,
        senderDisplayName: socket.user.profile?.displayName,
        senderAvatar: socket.user.profile?.avatar,
        senderLevel: socket.user.profile?.level || 1,
        type,
        content: content.trim().substring(0, 500),
      });

      socket.emit('chat:dm:sent', message);
      io.to(`user:${toUserId}`).emit('chat:dm:received', message);
    } catch (err) {
      logger.error('chat:dm error', err);
    }
  });

  socket.on('chat:typing', ({ streamId }) => {
    if (socket.user && streamId) {
      socket.to(`stream:${streamId}`).emit(`chat:typing:${streamId}`, {
        userId: socket.user.userId,
        username: socket.user.username,
      });
    }
  });

  socket.on('chat:reaction', async (data) => {
    try {
      const { messageId, emoji, streamId } = data;
      if (!socket.user) return;

      const message = await ChatMessage.findById(messageId);
      if (!message) return;

      const existing = message.reactions.find(r => r.emoji === emoji);
      if (existing) {
        if (existing.users.includes(socket.user._id)) {
          existing.users.pull(socket.user._id);
          existing.count = Math.max(0, existing.count - 1);
        } else {
          existing.users.push(socket.user._id);
          existing.count += 1;
        }
      } else {
        message.reactions.push({ emoji, count: 1, users: [socket.user._id] });
      }

      await message.save();

      io.to(`stream:${streamId}`).emit(`chat:reaction:${streamId}`, {
        messageId,
        reactions: message.reactions,
      });
    } catch (err) {
      logger.error('chat:reaction error', err);
    }
  });

  if (socket.user) {
    socket.join(`user:${socket.user.userId}`);
  }
};
