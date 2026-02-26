const { Achievement, UserAchievement } = require('../models/Achievement');
const User = require('../models/User');
const { getFromCache, setCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.getAllAchievements = async (req, res, next) => {
  try {
    const cacheKey = 'achievements:all';
    let achievements = await getFromCache(cacheKey);

    if (!achievements) {
      achievements = await Achievement.find({ isActive: true })
        .sort({ category: 1, sortOrder: 1 })
        .lean();
      await setCache(cacheKey, achievements, 3600);
    }

    res.json({ success: true, data: achievements });
  } catch (error) {
    next(error);
  }
};

exports.getUserAchievements = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const targetUser = await User.findOne({ userId, isActive: true }).lean();
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const [allAchievements, userAchievements] = await Promise.all([
      Achievement.find({ isActive: true, isHidden: false }).lean(),
      UserAchievement.find({ userId: targetUser._id }).lean(),
    ]);

    const achievementMap = {};
    for (const ua of userAchievements) {
      achievementMap[ua.achievementKey] = ua;
    }

    const result = allAchievements.map(achievement => ({
      ...achievement,
      userProgress: achievementMap[achievement.key] || null,
      isUnlocked: achievementMap[achievement.key]?.isUnlocked || false,
      progress: achievementMap[achievement.key]?.progress || 0,
      unlockedAt: achievementMap[achievement.key]?.unlockedAt || null,
    }));

    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.getMyAchievements = async (req, res, next) => {
  try {
    const userAchievements = await UserAchievement.find({
      userId: req.user._id,
      isUnlocked: true,
    }).lean();

    const achievementKeys = userAchievements.map(ua => ua.achievementKey);
    const achievements = await Achievement.find({ key: { $in: achievementKeys } }).lean();

    const achievementMap = {};
    for (const a of achievements) {
      achievementMap[a.key] = a;
    }

    const result = userAchievements.map(ua => ({
      ...achievementMap[ua.achievementKey],
      unlockedAt: ua.unlockedAt,
      progress: ua.progress,
    }));

    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.getLeaderboard = async (req, res, next) => {
  try {
    const { type = 'gifters', period = 'weekly' } = req.query;
    const limit = parseInt(req.query.limit) || 20;

    const now = new Date();
    let startDate;

    if (period === 'daily') {
      startDate = new Date(now.setHours(0, 0, 0, 0));
    } else if (period === 'weekly') {
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - now.getDay());
      weekStart.setHours(0, 0, 0, 0);
      startDate = weekStart;
    } else if (period === 'monthly') {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    const GiftTransaction = require('../models/GiftTransaction');
    const Stream = require('../models/Stream');

    let pipeline;

    if (type === 'gifters') {
      const matchQuery = { status: 'completed' };
      if (startDate) matchQuery.createdAt = { $gte: startDate };

      pipeline = await GiftTransaction.aggregate([
        { $match: matchQuery },
        { $group: { _id: '$senderId', totalCoins: { $sum: '$coinCost' }, giftCount: { $sum: '$quantity' } } },
        { $sort: { totalCoins: -1 } },
        { $limit: limit },
        {
          $lookup: {
            from: 'users',
            localField: '_id',
            foreignField: '_id',
            as: 'user',
          },
        },
        { $unwind: '$user' },
        {
          $project: {
            totalCoins: 1,
            giftCount: 1,
            'user.userId': 1,
            'user.username': 1,
            'user.profile.displayName': 1,
            'user.profile.avatar': 1,
            'user.profile.level': 1,
          },
        },
      ]);
    } else if (type === 'streamers') {
      const matchQuery = {};
      if (startDate) matchQuery.createdAt = { $gte: startDate };

      pipeline = await Stream.aggregate([
        { $match: { ...matchQuery, status: { $in: ['ended', 'live'] } } },
        { $group: { _id: '$streamerId', totalViews: { $sum: '$stats.totalViews' }, streamCount: { $sum: 1 } } },
        { $sort: { totalViews: -1 } },
        { $limit: limit },
        {
          $lookup: {
            from: 'users',
            localField: '_id',
            foreignField: '_id',
            as: 'user',
          },
        },
        { $unwind: '$user' },
        {
          $project: {
            totalViews: 1,
            streamCount: 1,
            'user.userId': 1,
            'user.username': 1,
            'user.profile.displayName': 1,
            'user.profile.avatar': 1,
            'user.profile.level': 1,
          },
        },
      ]);
    } else {
      pipeline = [];
    }

    res.json({ success: true, data: pipeline });
  } catch (error) {
    next(error);
  }
};
