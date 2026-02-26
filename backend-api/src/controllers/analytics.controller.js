const Stream = require('../models/Stream');
const GiftTransaction = require('../models/GiftTransaction');
const Follow = require('../models/Follow');
const User = require('../models/User');
const { getPostgresPool } = require('../config/database');
const logger = require('../utils/logger');

exports.getStreamerDashboard = async (req, res, next) => {
  try {
    const now = new Date();
    const thirtyDaysAgo = new Date(now - 30 * 24 * 60 * 60 * 1000);
    const sevenDaysAgo = new Date(now - 7 * 24 * 60 * 60 * 1000);

    const [recentStreams, totalStreams, giftStats, followerGrowth, liveStream] = await Promise.all([
      Stream.find({
        streamerId: req.user._id,
        status: { $in: ['ended', 'replay'] },
        createdAt: { $gte: thirtyDaysAgo },
      })
        .sort({ createdAt: -1 })
        .select('streamId title stats monetization startedAt endedAt createdAt')
        .lean(),

      Stream.countDocuments({ streamerId: req.user._id, status: { $in: ['ended', 'replay'] } }),

      GiftTransaction.aggregate([
        { $match: { receiverId: req.user._id, createdAt: { $gte: thirtyDaysAgo } } },
        {
          $group: {
            _id: null,
            totalDiamonds: { $sum: '$netDiamonds' },
            totalGifts: { $sum: '$quantity' },
            topSender: { $first: '$senderId' },
          },
        },
      ]),

      Follow.aggregate([
        { $match: { followingId: req.user._id, createdAt: { $gte: sevenDaysAgo } } },
        {
          $group: {
            _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
            count: { $sum: 1 },
          },
        },
        { $sort: { _id: 1 } },
      ]),

      Stream.findOne({ streamerId: req.user._id, status: 'live' })
        .select('streamId stats monetization startedAt')
        .lean(),
    ]);

    const totalViews = recentStreams.reduce((sum, s) => sum + (s.stats?.totalViews || 0), 0);
    const totalWatchTime = recentStreams.reduce((sum, s) => sum + (s.stats?.duration || 0), 0);
    const avgViewers = recentStreams.length > 0
      ? Math.round(recentStreams.reduce((sum, s) => sum + (s.stats?.peakViewers || 0), 0) / recentStreams.length)
      : 0;

    res.json({
      success: true,
      data: {
        summary: {
          totalStreams,
          recentStreams: recentStreams.length,
          totalViews,
          totalWatchTime,
          avgPeakViewers: avgViewers,
          diamondsEarned: giftStats[0]?.totalDiamonds || 0,
          giftsReceived: giftStats[0]?.totalGifts || 0,
        },
        recentStreams: recentStreams.slice(0, 10),
        followerGrowth,
        liveStream,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getStreamAnalytics = async (req, res, next) => {
  try {
    const { streamId } = req.params;

    const stream = await Stream.findOne({ streamId, streamerId: req.user._id })
      .populate('streamerId', 'userId username profile.displayName')
      .lean();

    if (!stream) {
      return res.status(404).json({ success: false, message: 'Stream not found' });
    }

    const giftBreakdown = await GiftTransaction.aggregate([
      { $match: { streamId, status: 'completed' } },
      {
        $lookup: {
          from: 'gifts',
          localField: 'giftId',
          foreignField: '_id',
          as: 'gift',
        },
      },
      { $unwind: '$gift' },
      {
        $group: {
          _id: '$gift.name',
          count: { $sum: '$quantity' },
          totalCoins: { $sum: '$coinCost' },
          totalDiamonds: { $sum: '$netDiamonds' },
        },
      },
      { $sort: { totalCoins: -1 } },
      { $limit: 10 },
    ]);

    const topGifters = await GiftTransaction.aggregate([
      { $match: { streamId, status: 'completed' } },
      { $group: { _id: '$senderId', totalCoins: { $sum: '$coinCost' }, count: { $sum: '$quantity' } } },
      { $sort: { totalCoins: -1 } },
      { $limit: 10 },
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
          count: 1,
          'user.userId': 1,
          'user.username': 1,
          'user.profile.displayName': 1,
          'user.profile.avatar': 1,
        },
      },
    ]);

    res.json({
      success: true,
      data: {
        stream,
        giftBreakdown,
        topGifters,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getEarningsReport = async (req, res, next) => {
  try {
    const { period = 'monthly' } = req.query;
    const now = new Date();
    let startDate;

    if (period === 'weekly') {
      startDate = new Date(now - 7 * 24 * 60 * 60 * 1000);
    } else if (period === 'monthly') {
      startDate = new Date(now.getFullYear(), now.getMonth(), 1);
    } else if (period === 'yearly') {
      startDate = new Date(now.getFullYear(), 0, 1);
    } else {
      startDate = new Date(0);
    }

    const [giftsData, user] = await Promise.all([
      GiftTransaction.aggregate([
        {
          $match: {
            receiverId: req.user._id,
            status: 'completed',
            createdAt: { $gte: startDate },
          },
        },
        {
          $group: {
            _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
            diamonds: { $sum: '$netDiamonds' },
            giftCount: { $sum: '$quantity' },
          },
        },
        { $sort: { _id: 1 } },
      ]),
      User.findById(req.user._id).select('wallet').lean(),
    ]);

    const totalDiamonds = giftsData.reduce((sum, d) => sum + d.diamonds, 0);

    res.json({
      success: true,
      data: {
        period,
        totalDiamonds,
        estimatedUSD: (totalDiamonds * 0.005).toFixed(2),
        dailyBreakdown: giftsData,
        wallet: user.wallet,
      },
    });
  } catch (error) {
    next(error);
  }
};
