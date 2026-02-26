const Stream = require('../models/Stream');
const User = require('../models/User');
const Event = require('../models/Event');
const { getFromCache, setCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.getLiveStreams = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { category, sort = 'viewers' } = req.query;

    const query = { status: 'live', 'settings.privacy': 'public' };
    if (category) query.category = category;

    const sortOptions = {
      viewers: { 'stats.currentViewers': -1 },
      trending: { trendingScore: -1 },
      new: { startedAt: -1 },
    };

    const sortOrder = sortOptions[sort] || sortOptions.viewers;

    const [streams, total] = await Promise.all([
      Stream.find(query)
        .sort(sortOrder)
        .skip(skip)
        .limit(limit)
        .populate('streamerId', 'userId username profile.displayName profile.avatar profile.verified')
        .select('-agora.token -rtmp.streamKey -rtmp.pushUrl -blockedUsers -activeViewers')
        .lean(),
      Stream.countDocuments(query),
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

exports.getTrendingStreams = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;
    const cacheKey = `trending:streams:${limit}`;

    let streams = await getFromCache(cacheKey);
    if (!streams) {
      streams = await Stream.find({ status: 'live', 'settings.privacy': 'public' })
        .sort({ trendingScore: -1 })
        .limit(limit)
        .populate('streamerId', 'userId username profile.displayName profile.avatar profile.verified')
        .select('-agora.token -rtmp.streamKey -rtmp.pushUrl -blockedUsers -activeViewers')
        .lean();

      await setCache(cacheKey, streams, 60);
    }

    res.json({ success: true, data: streams });
  } catch (error) {
    next(error);
  }
};

exports.getCategories = async (req, res, next) => {
  try {
    const cacheKey = 'discover:categories';
    let categories = await getFromCache(cacheKey);

    if (!categories) {
      const result = await Stream.aggregate([
        { $match: { status: 'live', 'settings.privacy': 'public' } },
        { $group: { _id: '$category', count: { $sum: 1 }, viewers: { $sum: '$stats.currentViewers' } } },
        { $sort: { viewers: -1 } },
      ]);

      categories = result.map(r => ({ name: r._id, streamCount: r.count, viewerCount: r.viewers }));
      await setCache(cacheKey, categories, 120);
    }

    res.json({ success: true, data: categories });
  } catch (error) {
    next(error);
  }
};

exports.search = async (req, res, next) => {
  try {
    const { q, type = 'all', page = 1, limit = 20 } = req.query;

    if (!q || q.trim().length < 2) {
      return res.status(400).json({ success: false, message: 'Search query must be at least 2 characters' });
    }

    const skip = (parseInt(page) - 1) * parseInt(limit);
    const results = {};

    if (type === 'all' || type === 'streams') {
      results.streams = await Stream.find(
        {
          $text: { $search: q },
          status: { $in: ['live', 'replay'] },
          'settings.privacy': 'public',
        },
        { score: { $meta: 'textScore' } }
      )
        .sort({ score: { $meta: 'textScore' } })
        .limit(parseInt(limit))
        .populate('streamerId', 'userId username profile.displayName profile.avatar')
        .select('streamId title thumbnail category stats status startedAt')
        .lean();
    }

    if (type === 'all' || type === 'users') {
      results.users = await User.find(
        {
          $text: { $search: q },
          isActive: true,
          'moderation.isBanned': false,
        },
        { score: { $meta: 'textScore' } }
      )
        .sort({ score: { $meta: 'textScore' }, 'stats.followers': -1 })
        .skip(skip)
        .limit(parseInt(limit))
        .select('userId username profile.displayName profile.avatar profile.verified stats.followers')
        .lean();
    }

    res.json({ success: true, data: results });
  } catch (error) {
    next(error);
  }
};

exports.getNearbyStreams = async (req, res, next) => {
  try {
    const { lat, lng, radius = 50 } = req.query;

    if (!lat || !lng) {
      return res.status(400).json({ success: false, message: 'Location coordinates required' });
    }

    const streams = await Stream.find({
      status: 'live',
      'settings.privacy': 'public',
      location: {
        $near: {
          $geometry: { type: 'Point', coordinates: [parseFloat(lng), parseFloat(lat)] },
          $maxDistance: parseInt(radius) * 1000,
        },
      },
    })
      .limit(20)
      .populate('streamerId', 'userId username profile.displayName profile.avatar')
      .select('streamId title thumbnail category stats location startedAt')
      .lean();

    res.json({ success: true, data: streams });
  } catch (error) {
    next(error);
  }
};

exports.getFollowingStreams = async (req, res, next) => {
  try {
    if (!req.user) {
      return res.json({ success: true, data: [] });
    }

    const Follow = require('../models/Follow');
    const following = await Follow.find({ followerId: req.user._id }).select('followingId').lean();
    const followingIds = following.map(f => f.followingId);

    const streams = await Stream.find({
      streamerId: { $in: followingIds },
      status: 'live',
      'settings.privacy': { $ne: 'private' },
    })
      .sort({ startedAt: -1 })
      .limit(20)
      .populate('streamerId', 'userId username profile.displayName profile.avatar profile.verified')
      .select('streamId title thumbnail category stats startedAt')
      .lean();

    res.json({ success: true, data: streams });
  } catch (error) {
    next(error);
  }
};

exports.getRecommended = async (req, res, next) => {
  try {
    const limit = parseInt(req.query.limit) || 10;

    const streams = await Stream.find({
      status: 'live',
      'settings.privacy': 'public',
      'stats.currentViewers': { $gt: 0 },
    })
      .sort({ trendingScore: -1, 'stats.currentViewers': -1 })
      .limit(limit)
      .populate('streamerId', 'userId username profile.displayName profile.avatar profile.verified')
      .select('streamId title thumbnail category stats startedAt trendingScore')
      .lean();

    res.json({ success: true, data: streams });
  } catch (error) {
    next(error);
  }
};
