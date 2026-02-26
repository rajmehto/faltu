const Stream = require('../models/Stream');
const { setCache, deleteCache, incrementCounter } = require('../config/redis');
const logger = require('../utils/logger');

module.exports = function (io, socket) {
  socket.on('stream:like', async ({ streamId }) => {
    if (!socket.user) return;

    try {
      const likeKey = `stream:like:${streamId}:${socket.user.userId}`;
      const alreadyLiked = await incrementCounter(likeKey, 86400);

      if (alreadyLiked > 1) return;

      const stream = await Stream.findOneAndUpdate(
        { streamId },
        { $inc: { 'stats.likes': 1 } },
        { new: true }
      ).select('stats.likes');

      io.to(`stream:${streamId}`).emit(`stream:likes:${streamId}`, {
        likes: stream?.stats?.likes || 0,
      });
    } catch (err) {
      logger.error('stream:like error', err);
    }
  });

  socket.on('stream:viewer:update', async ({ streamId, count }) => {
    try {
      if (!streamId) return;

      const roomSize = io.sockets.adapter.rooms.get(`stream:${streamId}`)?.size || 0;

      const stream = await Stream.findOneAndUpdate(
        { streamId, status: 'live' },
        {
          $set: { 'stats.currentViewers': roomSize },
          $max: { 'stats.peakViewers': roomSize },
          $inc: { 'stats.totalViews': 0 },
        },
        { new: true }
      ).select('stats.currentViewers stats.peakViewers');

      if (stream) {
        stream.updateTrendingScore?.();
        await stream.save?.();

        io.to(`stream:${streamId}`).emit(`stream:viewers:${streamId}`, {
          currentViewers: roomSize,
          peakViewers: stream.stats?.peakViewers,
        });
      }
    } catch (err) {
      logger.error('stream:viewer:update error', err);
    }
  });

  socket.on('stream:cohost:invite', async ({ streamId, userId }) => {
    if (!socket.user) return;

    try {
      const stream = await Stream.findOne({ streamId, streamerId: socket.user._id, status: 'live' }).lean();
      if (!stream) return;

      io.to(`user:${userId}`).emit('stream:cohost:invited', {
        streamId,
        invitedBy: {
          userId: socket.user.userId,
          displayName: socket.user.profile?.displayName,
        },
      });
    } catch (err) {
      logger.error('stream:cohost:invite error', err);
    }
  });

  socket.on('stream:cohost:accept', async ({ streamId }) => {
    if (!socket.user) return;

    try {
      await Stream.findOneAndUpdate(
        { streamId, status: 'live' },
        { $addToSet: { coHosts: socket.user._id } }
      );

      io.to(`stream:${streamId}`).emit(`stream:cohost:joined:${streamId}`, {
        userId: socket.user.userId,
        username: socket.user.username,
        displayName: socket.user.profile?.displayName,
        avatar: socket.user.profile?.avatar,
      });
    } catch (err) {
      logger.error('stream:cohost:accept error', err);
    }
  });

  socket.on('stream:cohost:remove', async ({ streamId, userId }) => {
    if (!socket.user) return;

    try {
      const User = require('../models/User');
      const targetUser = await User.findOne({ userId }).lean();
      if (!targetUser) return;

      await Stream.findOneAndUpdate(
        { streamId, streamerId: socket.user._id },
        { $pull: { coHosts: targetUser._id } }
      );

      io.to(`stream:${streamId}`).emit(`stream:cohost:removed:${streamId}`, { userId });
      io.to(`user:${userId}`).emit('stream:cohost:removed', { streamId });
    } catch (err) {
      logger.error('stream:cohost:remove error', err);
    }
  });

  socket.on('stream:mute_user', async ({ streamId, userId }) => {
    if (!socket.user) return;

    try {
      const stream = await Stream.findOne({ streamId, status: 'live' }).lean();
      if (!stream) return;

      const isStreamer = stream.streamerId.toString() === socket.user._id.toString();
      const isModerator = stream.moderators?.some(id => id.toString() === socket.user._id.toString());

      if (!isStreamer && !isModerator) return;

      io.to(`user:${userId}`).emit('stream:muted', { streamId, reason: 'Muted by moderator' });
    } catch (err) {
      logger.error('stream:mute_user error', err);
    }
  });

  socket.on('stream:kick_user', async ({ streamId, userId }) => {
    if (!socket.user) return;

    try {
      const stream = await Stream.findOne({ streamId, status: 'live' }).lean();
      if (!stream) return;

      const isStreamer = stream.streamerId.toString() === socket.user._id.toString();
      if (!isStreamer) return;

      const User = require('../models/User');
      const targetUser = await User.findOne({ userId }).lean();
      if (!targetUser) return;

      await Stream.findOneAndUpdate({ streamId }, { $addToSet: { blockedUsers: targetUser._id } });

      io.to(`user:${userId}`).emit('stream:kicked', { streamId });
    } catch (err) {
      logger.error('stream:kick_user error', err);
    }
  });

  socket.on('stream:share', async ({ streamId }) => {
    try {
      await Stream.findOneAndUpdate({ streamId }, { $inc: { 'stats.shares': 1 } });
    } catch (err) {
      logger.error('stream:share error', err);
    }
  });

  socket.on('stream:view:start', async ({ streamId }) => {
    try {
      await Stream.findOneAndUpdate(
        { streamId, status: 'live' },
        { $inc: { 'stats.totalViews': 1 } }
      );
    } catch (err) {
      logger.error('stream:view:start error', err);
    }
  });
};
