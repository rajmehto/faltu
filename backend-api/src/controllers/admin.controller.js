const User = require('../models/User');
const Stream = require('../models/Stream');
const Report = require('../models/Report');
const GiftTransaction = require('../models/GiftTransaction');
const { getPostgresPool } = require('../config/database');
const { deleteCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.getDashboardStats = async (req, res, next) => {
  try {
    const now = new Date();
    const todayStart = new Date(now.setHours(0, 0, 0, 0));
    const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);

    const [
      totalUsers,
      newUsersToday,
      newUsersThisMonth,
      liveStreams,
      totalStreams,
      pendingReports,
    ] = await Promise.all([
      User.countDocuments({ isActive: true }),
      User.countDocuments({ createdAt: { $gte: todayStart } }),
      User.countDocuments({ createdAt: { $gte: monthStart } }),
      Stream.countDocuments({ status: 'live' }),
      Stream.countDocuments({ status: { $in: ['ended', 'live'] } }),
      Report.countDocuments({ status: 'pending' }),
    ]);

    const pool = getPostgresPool();
    const revenueResult = await pool.query(
      `SELECT COALESCE(SUM(CAST(metadata->>'usdAmount' AS DECIMAL)), 0) as total
       FROM wallet_transactions
       WHERE transaction_type = 'coin_purchase' AND created_at >= $1`,
      [monthStart]
    ).catch(() => ({ rows: [{ total: 0 }] }));

    res.json({
      success: true,
      data: {
        users: { total: totalUsers, newToday: newUsersToday, newThisMonth: newUsersThisMonth },
        streams: { live: liveStreams, total: totalStreams },
        reports: { pending: pendingReports },
        revenue: { thisMonth: parseFloat(revenueResult.rows[0].total || 0) },
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getUsers = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { search, status, banned } = req.query;

    const query = {};
    if (status === 'active') query.isActive = true;
    if (status === 'deleted') query.isActive = false;
    if (banned === 'true') query['moderation.isBanned'] = true;

    if (search) {
      query.$or = [
        { username: new RegExp(search, 'i') },
        { email: new RegExp(search, 'i') },
        { 'profile.displayName': new RegExp(search, 'i') },
      ];
    }

    const [users, total] = await Promise.all([
      User.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .select('userId username email profile.displayName profile.avatar stats moderation isActive createdAt')
        .lean(),
      User.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: users,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.banUser = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { reason, duration, permanent = false } = req.body;

    if (!reason) {
      return res.status(400).json({ success: false, message: 'Ban reason is required' });
    }

    const user = await User.findOne({ userId });
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const banUntil = permanent ? null : duration ? new Date(Date.now() + duration * 60 * 60 * 1000) : null;

    user.moderation.isBanned = true;
    user.moderation.banReason = reason;
    user.moderation.banUntil = banUntil;
    user.moderation.isPermanentBan = permanent;
    user.auth.refreshTokens = [];
    await user.save();

    await deleteCache(`user:${userId}`);
    await deleteCache(`profile:${userId}`);

    await Stream.updateMany(
      { streamerId: user._id, status: 'live' },
      { $set: { status: 'ended', endedAt: new Date() } }
    );

    res.json({ success: true, message: `User ${permanent ? 'permanently' : 'temporarily'} banned` });
  } catch (error) {
    next(error);
  }
};

exports.unbanUser = async (req, res, next) => {
  try {
    const { userId } = req.params;

    await User.findOneAndUpdate(
      { userId },
      {
        $set: {
          'moderation.isBanned': false,
          'moderation.banReason': null,
          'moderation.banUntil': null,
          'moderation.isPermanentBan': false,
        },
      }
    );

    await deleteCache(`user:${userId}`);
    await deleteCache(`profile:${userId}`);

    res.json({ success: true, message: 'User unbanned' });
  } catch (error) {
    next(error);
  }
};

exports.getReports = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { status = 'pending', targetType } = req.query;

    const query = { status };
    if (targetType) query.targetType = targetType;

    const [reports, total] = await Promise.all([
      Report.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('reporterId', 'userId username profile.displayName')
        .populate('reviewedBy', 'userId username')
        .lean(),
      Report.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: reports,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.resolveReport = async (req, res, next) => {
  try {
    const { reportId } = req.params;
    const { resolution, actionTaken, status = 'resolved' } = req.body;

    const report = await Report.findById(reportId);
    if (!report) {
      return res.status(404).json({ success: false, message: 'Report not found' });
    }

    report.status = status;
    report.resolution = resolution;
    report.actionTaken = actionTaken;
    report.reviewedBy = req.user._id;
    report.reviewedAt = new Date();
    await report.save();

    res.json({ success: true, data: report, message: 'Report resolved' });
  } catch (error) {
    next(error);
  }
};

exports.getLiveStreams = async (req, res, next) => {
  try {
    const streams = await Stream.find({ status: 'live' })
      .sort({ startedAt: -1 })
      .populate('streamerId', 'userId username profile.displayName profile.avatar')
      .select('streamId title category stats startedAt aiModeration reportCount')
      .lean();

    res.json({ success: true, data: streams });
  } catch (error) {
    next(error);
  }
};

exports.terminateStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { reason } = req.body;

    const stream = await Stream.findOneAndUpdate(
      { streamId },
      {
        $set: {
          status: 'ended',
          endedAt: new Date(),
          'aiModeration.autoTerminated': true,
          'aiModeration.terminationReason': reason || 'Admin action',
        },
      },
      { new: true }
    );

    if (!stream) {
      return res.status(404).json({ success: false, message: 'Stream not found' });
    }

    res.json({ success: true, message: 'Stream terminated' });
  } catch (error) {
    next(error);
  }
};

exports.submitReport = async (req, res, next) => {
  try {
    const { targetType, targetId, reason, description, screenshotUrls } = req.body;

    if (!targetType || !targetId || !reason) {
      return res.status(400).json({ success: false, message: 'targetType, targetId, and reason are required' });
    }

    const existing = await Report.findOne({
      reporterId: req.user._id,
      targetId,
      targetType,
      status: 'pending',
    }).lean();

    if (existing) {
      return res.status(409).json({ success: false, message: 'You have already reported this' });
    }

    const report = await Report.create({
      reporterId: req.user._id,
      targetType,
      targetId,
      reason,
      description,
      screenshotUrls: screenshotUrls || [],
    });

    if (targetType === 'stream') {
      await Stream.findOneAndUpdate({ streamId: targetId }, { $inc: { reportCount: 1 } });
    }

    res.status(201).json({ success: true, data: report, message: 'Report submitted successfully' });
  } catch (error) {
    next(error);
  }
};
