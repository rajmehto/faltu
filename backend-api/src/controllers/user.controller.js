const User = require('../models/User');
const Follow = require('../models/Follow');
const Block = require('../models/Block');
const Stream = require('../models/Stream');
const { setCache, deleteCache, getFromCache } = require('../config/redis');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

exports.getProfile = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const cacheKey = `profile:${userId}`;
    let user = await getFromCache(cacheKey);

    if (!user) {
      user = await User.findOne({
        $or: [{ userId }, { username: userId }],
        isActive: true,
        deletedAt: null,
      }).select('-auth -moderation.warnings').lean();

      if (!user) {
        return res.status(404).json({ success: false, message: 'User not found' });
      }

      await setCache(cacheKey, user, 120);
    }

    let isFollowing = false;
    let isBlocked = false;

    if (req.user && req.user._id.toString() !== user._id.toString()) {
      const [followDoc, blockDoc] = await Promise.all([
        Follow.findOne({ followerId: req.user._id, followingId: user._id }).lean(),
        Block.findOne({ blockerId: req.user._id, blockedId: user._id }).lean(),
      ]);
      isFollowing = !!followDoc;
      isBlocked = !!blockDoc;
    }

    res.json({
      success: true,
      data: {
        ...user,
        isFollowing,
        isBlocked,
        isOwnProfile: req.user?._id.toString() === user._id.toString(),
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.updateProfile = async (req, res, next) => {
  try {
    const allowedFields = [
      'profile.displayName', 'profile.bio', 'profile.birthday', 'profile.gender',
      'profile.country', 'profile.city', 'profile.avatar', 'profile.coverImage',
      'socialLinks.instagram', 'socialLinks.youtube', 'socialLinks.tiktok', 'socialLinks.twitter',
    ];

    const updates = {};
    for (const field of allowedFields) {
      const keys = field.split('.');
      if (keys.length === 2 && req.body[keys[0]]?.[keys[1]] !== undefined) {
        updates[field] = req.body[keys[0]][keys[1]];
      } else if (keys.length === 1 && req.body[keys[0]] !== undefined) {
        updates[field] = req.body[keys[0]];
      }
    }

    if (req.body.username) {
      const existing = await User.findOne({ username: req.body.username });
      if (existing && existing._id.toString() !== req.user._id.toString()) {
        return res.status(409).json({ success: false, message: 'Username already taken' });
      }
      updates.username = req.body.username.toLowerCase();
    }

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updates },
      { new: true, runValidators: true }
    ).select('-auth -moderation.warnings');

    await deleteCache(`profile:${req.user.userId}`);
    await deleteCache(`user:${req.user.userId}`);

    res.json({ success: true, data: user, message: 'Profile updated successfully' });
  } catch (error) {
    next(error);
  }
};

exports.updateSettings = async (req, res, next) => {
  try {
    const { notifications, privacy, theme, language } = req.body;
    const updates = {};

    if (notifications) {
      for (const [key, value] of Object.entries(notifications)) {
        updates[`settings.notifications.${key}`] = value;
      }
    }
    if (privacy) {
      for (const [key, value] of Object.entries(privacy)) {
        updates[`settings.privacy.${key}`] = value;
      }
    }
    if (theme) updates['settings.theme'] = theme;
    if (language) updates['settings.language'] = language;

    const user = await User.findByIdAndUpdate(
      req.user._id,
      { $set: updates },
      { new: true }
    ).select('settings');

    await deleteCache(`user:${req.user.userId}`);

    res.json({ success: true, data: user.settings, message: 'Settings updated' });
  } catch (error) {
    next(error);
  }
};

exports.followUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (targetUser._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ success: false, message: 'Cannot follow yourself' });
    }

    const blocked = await Block.findOne({ blockerId: targetUser._id, blockedId: req.user._id }).lean();
    if (blocked) {
      return res.status(403).json({ success: false, message: 'Cannot follow this user' });
    }

    const existing = await Follow.findOne({ followerId: req.user._id, followingId: targetUser._id }).lean();
    if (existing) {
      return res.status(409).json({ success: false, message: 'Already following' });
    }

    await Follow.create({ followerId: req.user._id, followingId: targetUser._id });

    await Promise.all([
      User.findByIdAndUpdate(req.user._id, { $inc: { 'stats.following': 1 } }),
      User.findByIdAndUpdate(targetUser._id, { $inc: { 'stats.followers': 1 } }),
    ]);

    await deleteCache(`profile:${targetUser.userId}`);
    await deleteCache(`profile:${req.user.userId}`);

    res.json({ success: true, message: 'Followed successfully' });
  } catch (error) {
    next(error);
  }
};

exports.unfollowUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const deleted = await Follow.findOneAndDelete({
      followerId: req.user._id,
      followingId: targetUser._id,
    });

    if (!deleted) {
      return res.status(404).json({ success: false, message: 'Not following this user' });
    }

    await Promise.all([
      User.findByIdAndUpdate(req.user._id, { $inc: { 'stats.following': -1 } }),
      User.findByIdAndUpdate(targetUser._id, { $inc: { 'stats.followers': -1 } }),
    ]);

    await deleteCache(`profile:${targetUser.userId}`);
    await deleteCache(`profile:${req.user.userId}`);

    res.json({ success: true, message: 'Unfollowed successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getFollowers = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const [follows, total] = await Promise.all([
      Follow.find({ followingId: targetUser._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('followerId', 'userId username profile.displayName profile.avatar profile.level profile.verified stats.followers')
        .lean(),
      Follow.countDocuments({ followingId: targetUser._id }),
    ]);

    const followers = follows.map(f => f.followerId);

    res.json({
      success: true,
      data: followers,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.getFollowing = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const [follows, total] = await Promise.all([
      Follow.find({ followerId: targetUser._id })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('followingId', 'userId username profile.displayName profile.avatar profile.level profile.verified stats.followers')
        .lean(),
      Follow.countDocuments({ followerId: targetUser._id }),
    ]);

    const following = follows.map(f => f.followingId);

    res.json({
      success: true,
      data: following,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.blockUser = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { reason } = req.body;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (targetUser._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ success: false, message: 'Cannot block yourself' });
    }

    await Block.findOneAndUpdate(
      { blockerId: req.user._id, blockedId: targetUser._id },
      { blockerId: req.user._id, blockedId: targetUser._id, reason },
      { upsert: true }
    );

    await Follow.deleteMany({
      $or: [
        { followerId: req.user._id, followingId: targetUser._id },
        { followerId: targetUser._id, followingId: req.user._id },
      ],
    });

    res.json({ success: true, message: 'User blocked successfully' });
  } catch (error) {
    next(error);
  }
};

exports.unblockUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    await Block.findOneAndDelete({ blockerId: req.user._id, blockedId: targetUser._id });

    res.json({ success: true, message: 'User unblocked successfully' });
  } catch (error) {
    next(error);
  }
};

exports.searchUsers = async (req, res, next) => {
  try {
    const { q, page = 1, limit = 20 } = req.query;
    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, message: 'Search query must be at least 2 characters' });
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);

    const users = await User.find(
      {
        $text: { $search: q },
        isActive: true,
        deletedAt: null,
        'moderation.isBanned': false,
      },
      { score: { $meta: 'textScore' } }
    )
      .sort({ score: { $meta: 'textScore' }, 'stats.followers': -1 })
      .skip(skip)
      .limit(parseInt(limit))
      .select('userId username profile.displayName profile.avatar profile.verified profile.level stats.followers')
      .lean();

    res.json({ success: true, data: users });
  } catch (error) {
    next(error);
  }
};

exports.getSuggestions = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const following = await Follow.find({ followerId: req.user._id }).select('followingId').lean();
    const followingIds = following.map(f => f.followingId);
    followingIds.push(req.user._id);

    const users = await User.find({
      _id: { $nin: followingIds },
      isActive: true,
      deletedAt: null,
      'moderation.isBanned': false,
    })
      .sort({ 'stats.followers': -1 })
      .limit(limit)
      .select('userId username profile.displayName profile.avatar profile.verified profile.level stats.followers')
      .lean();

    res.json({ success: true, data: users });
  } catch (error) {
    next(error);
  }
};

exports.getBlockedUsers = async (req, res, next) => {
  try {
    const blocks = await Block.find({ blockerId: req.user._id })
      .sort({ createdAt: -1 })
      .populate('blockedId', 'userId username profile.displayName profile.avatar')
      .lean();

    const blockedUsers = blocks.map(b => ({ ...b.blockedId, blockedAt: b.createdAt }));

    res.json({ success: true, data: blockedUsers });
  } catch (error) {
    next(error);
  }
};

exports.getUserStreams = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 12;
    const skip = (page - 1) * limit;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const [streams, total] = await Promise.all([
      Stream.find({ streamerId: targetUser._id, status: { $in: ['ended', 'replay'] } })
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('streamId title thumbnail category stats startedAt endedAt status')
        .lean(),
      Stream.countDocuments({ streamerId: targetUser._id, status: { $in: ['ended', 'replay'] } }),
    ]);

    res.json({
      success: true,
      data: streams,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.updateFcmToken = async (req, res, next) => {
  try {
    const { fcmToken } = req.body;
    if (!fcmToken) {
      return res.status(400).json({ success: false, message: 'FCM token is required' });
    }

    await User.findByIdAndUpdate(req.user._id, { $set: { 'auth.fcmToken': fcmToken } });
    await deleteCache(`user:${req.user.userId}`);

    res.json({ success: true, message: 'FCM token updated' });
  } catch (error) {
    next(error);
  }
};

exports.deleteAccount = async (req, res, next) => {
  try {
    await User.findByIdAndUpdate(req.user._id, {
      $set: {
        isActive: false,
        deletedAt: new Date(),
        'auth.refreshTokens': [],
        email: `deleted_${req.user.userId}@deleted.com`,
        phone: null,
      },
    });

    await deleteCache(`user:${req.user.userId}`);
    await deleteCache(`profile:${req.user.userId}`);

    res.json({ success: true, message: 'Account deleted successfully' });
  } catch (error) {
    next(error);
  }
};
