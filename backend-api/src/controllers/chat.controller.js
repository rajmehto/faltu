const ChatMessage = require('../models/ChatMessage');
const User = require('../models/User');
const Stream = require('../models/Stream');
const Block = require('../models/Block');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

exports.getStreamMessages = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const limit = Math.min(parseInt(req.query.limit) || 50, 100);
    const before = req.query.before;

    const query = {
      streamId,
      isDeleted: false,
    };

    if (before) {
      query.createdAt = { $lt: new Date(before) };
    }

    const messages = await ChatMessage.find(query)
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    res.json({ success: true, data: messages.reverse() });
  } catch (error) {
    next(error);
  }
};

exports.sendMessage = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { content, type = 'text', replyTo, imageUrl, stickerUrl } = req.body;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Message content is required' });
    }

    const stream = await Stream.findOne({ streamId, status: 'live' }).lean();
    if (!stream) {
      return res.status(404).json({ success: false, message: 'Stream not found or not live' });
    }

    if (stream.blockedUsers?.includes(req.user._id)) {
      return res.status(403).json({ success: false, message: 'You are blocked from this stream' });
    }

    const message = await ChatMessage.create({
      streamId,
      senderId: req.user._id,
      senderUsername: req.user.username,
      senderDisplayName: req.user.profile.displayName,
      senderAvatar: req.user.profile.avatar,
      senderLevel: req.user.profile.level,
      type,
      content: content.trim().substring(0, 500),
      replyTo,
      imageUrl,
      stickerUrl,
    });

    await Stream.findOneAndUpdate({ streamId }, { $inc: { 'stats.comments': 1 } });

    res.status(201).json({ success: true, data: message });
  } catch (error) {
    next(error);
  }
};

exports.deleteMessage = async (req, res, next) => {
  try {
    const { messageId } = req.params;

    const message = await ChatMessage.findById(messageId);
    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    const stream = await Stream.findOne({ streamId: message.streamId }).lean();
    const isOwner = message.senderId.toString() === req.user._id.toString();
    const isStreamer = stream?.streamerId.toString() === req.user._id.toString();
    const isModerator = stream?.moderators?.includes(req.user._id);

    if (!isOwner && !isStreamer && !isModerator) {
      return res.status(403).json({ success: false, message: 'Insufficient permissions' });
    }

    message.isDeleted = true;
    message.deletedAt = new Date();
    message.deletedBy = req.user._id;
    await message.save();

    res.json({ success: true, message: 'Message deleted' });
  } catch (error) {
    next(error);
  }
};

exports.pinMessage = async (req, res, next) => {
  try {
    const { messageId } = req.params;

    const message = await ChatMessage.findById(messageId);
    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    const stream = await Stream.findOne({ streamId: message.streamId }).lean();
    const isStreamer = stream?.streamerId.toString() === req.user._id.toString();
    const isModerator = stream?.moderators?.includes(req.user._id);

    if (!isStreamer && !isModerator) {
      return res.status(403).json({ success: false, message: 'Insufficient permissions' });
    }

    await ChatMessage.updateMany({ streamId: message.streamId }, { $set: { isPinned: false } });

    message.isPinned = true;
    await message.save();

    await Stream.findOneAndUpdate({ streamId: message.streamId }, { $set: { pinnedMessage: message._id } });

    res.json({ success: true, data: message, message: 'Message pinned' });
  } catch (error) {
    next(error);
  }
};

exports.addReaction = async (req, res, next) => {
  try {
    const { messageId } = req.params;
    const { emoji } = req.body;

    if (!emoji) {
      return res.status(400).json({ success: false, message: 'Emoji is required' });
    }

    const message = await ChatMessage.findById(messageId);
    if (!message) {
      return res.status(404).json({ success: false, message: 'Message not found' });
    }

    const existingReaction = message.reactions.find(r => r.emoji === emoji);

    if (existingReaction) {
      if (existingReaction.users.includes(req.user._id)) {
        existingReaction.users.pull(req.user._id);
        existingReaction.count = Math.max(0, existingReaction.count - 1);
      } else {
        existingReaction.users.push(req.user._id);
        existingReaction.count += 1;
      }
    } else {
      message.reactions.push({ emoji, count: 1, users: [req.user._id] });
    }

    await message.save();

    res.json({ success: true, data: message.reactions });
  } catch (error) {
    next(error);
  }
};

exports.getDirectMessages = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const limit = parseInt(req.query.limit) || 30;
    const before = req.query.before;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const blocked = await Block.findOne({
      $or: [
        { blockerId: req.user._id, blockedId: targetUser._id },
        { blockerId: targetUser._id, blockedId: req.user._id },
      ],
    }).lean();

    if (blocked) {
      return res.status(403).json({ success: false, message: 'Cannot message this user' });
    }

    const dmRoomId = [req.user._id.toString(), targetUser._id.toString()].sort().join(':');

    const query = { roomId: dmRoomId, isDeleted: false };
    if (before) query.createdAt = { $lt: new Date(before) };

    const messages = await ChatMessage.find(query)
      .sort({ createdAt: -1 })
      .limit(limit)
      .lean();

    res.json({ success: true, data: messages.reverse() });
  } catch (error) {
    next(error);
  }
};

exports.sendDirectMessage = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { content, type = 'text', imageUrl } = req.body;

    if (!content || content.trim().length === 0) {
      return res.status(400).json({ success: false, message: 'Message content is required' });
    }

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const blocked = await Block.findOne({
      $or: [
        { blockerId: req.user._id, blockedId: targetUser._id },
        { blockerId: targetUser._id, blockedId: req.user._id },
      ],
    }).lean();

    if (blocked) {
      return res.status(403).json({ success: false, message: 'Cannot message this user' });
    }

    if (targetUser.settings?.privacy?.allowDirectMessages === 'none') {
      return res.status(403).json({ success: false, message: 'This user does not accept direct messages' });
    }

    const dmRoomId = [req.user._id.toString(), targetUser._id.toString()].sort().join(':');

    const message = await ChatMessage.create({
      roomId: dmRoomId,
      streamId: `dm:${dmRoomId}`,
      senderId: req.user._id,
      senderUsername: req.user.username,
      senderDisplayName: req.user.profile.displayName,
      senderAvatar: req.user.profile.avatar,
      senderLevel: req.user.profile.level,
      type,
      content: content.trim().substring(0, 500),
      imageUrl,
    });

    res.status(201).json({ success: true, data: message });
  } catch (error) {
    next(error);
  }
};

exports.getDMList = async (req, res, next) => {
  try {
    const userIdStr = req.user._id.toString();

    const latestMessages = await ChatMessage.aggregate([
      {
        $match: {
          roomId: { $regex: userIdStr },
          isDeleted: false,
        },
      },
      { $sort: { createdAt: -1 } },
      {
        $group: {
          _id: '$roomId',
          lastMessage: { $first: '$$ROOT' },
        },
      },
      { $sort: { 'lastMessage.createdAt': -1 } },
      { $limit: 20 },
    ]);

    const dmList = await Promise.all(
      latestMessages.map(async ({ _id: roomId, lastMessage }) => {
        const otherUserId = roomId.split(':').find(id => id !== userIdStr);
        const otherUser = await User.findById(otherUserId)
          .select('userId username profile.displayName profile.avatar')
          .lean();
        const unreadCount = await ChatMessage.countDocuments({
          roomId,
          senderId: { $ne: req.user._id },
          isRead: false,
          isDeleted: false,
        });
        return { user: otherUser, lastMessage, unreadCount };
      })
    );

    res.json({ success: true, data: dmList.filter(d => d.user) });
  } catch (error) {
    next(error);
  }
};
