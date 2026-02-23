const Stream = require('../models/Stream');
const streamService = require('../services/stream.service');
const { deleteCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.startStream = async (req, res, next) => {
  try {
    const {
      title, description, category, tags,
      privacy, recordingEnabled, thumbnail,
    } = req.body;

    const result = await streamService.startStream({
      streamerId: req.user._id,
      title,
      description,
      category,
      tags,
      privacy,
      recordingEnabled,
      thumbnail,
    });

    res.status(201).json({
      success: true,
      message: 'Stream started',
      data: {
        stream: result.stream,
        agoraConfig: result.agoraConfig,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.endStream = async (req, res, next) => {
  try {
    const { streamId } = req.body;
    const result = await streamService.endStream(streamId, req.user._id);

    res.json({
      success: true,
      message: 'Stream ended',
      data: result,
    });
  } catch (error) {
    next(error);
  }
};

exports.getStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;

    const stream = await Stream.findOne({ streamId })
      .populate('streamerId', 'username profile.displayName profile.avatar profile.verified profile.level profile.country')
      .lean();

    if (!stream) {
      return res.status(404).json({ success: false, message: 'Stream not found' });
    }

    res.json({ success: true, data: streamService.normalizeStream(stream) });
  } catch (error) {
    next(error);
  }
};

exports.getLiveStreams = async (req, res, next) => {
  try {
    const { page = 1, pageSize = 20, category, sortBy } = req.query;
    const result = await streamService.getLiveStreams({
      page: parseInt(page),
      pageSize: parseInt(pageSize),
      category,
      sortBy,
    });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.getTrendingStreams = async (req, res, next) => {
  try {
    const { page = 1, pageSize = 20 } = req.query;
    const result = await streamService.getLiveStreams({
      page: parseInt(page),
      pageSize: parseInt(pageSize),
      sortBy: 'trending',
    });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.getNearbyStreams = async (req, res, next) => {
  try {
    const { lat, lng, page = 1, pageSize = 20 } = req.query;

    const streams = await Stream.find({
      status: 'live',
      isHidden: false,
      location: {
        $near: {
          $geometry: {
            type: 'Point',
            coordinates: [parseFloat(lng), parseFloat(lat)],
          },
          $maxDistance: 100000,
        },
      },
    })
      .populate('streamerId', 'username profile.displayName profile.avatar profile.verified')
      .skip((page - 1) * pageSize)
      .limit(parseInt(pageSize))
      .lean();

    res.json({
      success: true,
      data: {
        items: streams.map(streamService.normalizeStream),
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        hasMore: streams.length === parseInt(pageSize),
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.getRecommendedStreams = async (req, res, next) => {
  try {
    const { page = 1, pageSize = 20 } = req.query;
    const result = await streamService.getLiveStreams({
      page: parseInt(page),
      pageSize: parseInt(pageSize),
      sortBy: 'viewers',
    });
    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.searchStreams = async (req, res, next) => {
  try {
    const { q, page = 1, pageSize = 20, category } = req.query;

    const query = {
      $text: { $search: q },
      status: 'live',
      isHidden: false,
    };
    if (category) query.category = category;

    const [streams, total] = await Promise.all([
      Stream.find(query, { score: { $meta: 'textScore' } })
        .populate('streamerId', 'username profile.displayName profile.avatar profile.verified')
        .sort({ score: { $meta: 'textScore' } })
        .skip((page - 1) * pageSize)
        .limit(parseInt(pageSize))
        .lean(),
      Stream.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: {
        items: streams.map(streamService.normalizeStream),
        total,
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        hasMore: page * pageSize < total,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.joinStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { password } = req.body;

    const stream = await Stream.findOne({ streamId, status: 'live' });
    if (!stream) {
      return res.status(404).json({ success: false, message: 'Stream not found' });
    }

    if (stream.settings.privacy === 'password_protected') {
      if (!password || password !== stream.settings.password) {
        return res.status(403).json({ success: false, message: 'Invalid stream password' });
      }
    }

    if (stream.settings.privacy === 'followers_only' && req.user) {
      const Follow = require('../models/Follow');
      const isFollowing = await Follow.exists({
        followerId: req.user._id,
        followingId: stream.streamerId,
      });
      if (!isFollowing && stream.streamerId.toString() !== req.user._id.toString()) {
        return res.status(403).json({ success: false, message: 'This stream is for followers only' });
      }
    }

    const blockedUsers = stream.blockedUsers.map(id => id.toString());
    if (req.user && blockedUsers.includes(req.user._id.toString())) {
      return res.status(403).json({ success: false, message: 'You are blocked from this stream' });
    }

    const result = await streamService.joinStream(streamId, req.user?._id || 'guest');

    res.json({ success: true, data: result });
  } catch (error) {
    next(error);
  }
};

exports.leaveStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    if (req.user) {
      await streamService.leaveStream(streamId, req.user._id);
    }
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
};

exports.likeStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    await Stream.updateOne({ streamId }, { $inc: { 'stats.likes': 1 } });
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
};

exports.shareStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    await Stream.updateOne({ streamId }, { $inc: { 'stats.shares': 1 } });
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
};

exports.reportStream = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { reason, description } = req.body;

    await Stream.updateOne({ streamId }, { $inc: { reportCount: 1 } });

    const Report = require('../models/Report');
    await Report.create({
      reporterId: req.user._id,
      reportedStreamId: (await Stream.findOne({ streamId }))._id,
      type: 'stream',
      reason,
      description,
    });

    res.json({ success: true, message: 'Stream reported' });
  } catch (error) {
    next(error);
  }
};

exports.addCoHost = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { userId } = req.body;

    const stream = await Stream.findOne({ streamId });
    if (!stream || stream.streamerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    await Stream.updateOne({ streamId }, { $addToSet: { coHosts: userId } });

    res.json({ success: true, message: 'Co-host added' });
  } catch (error) {
    next(error);
  }
};

exports.removeCoHost = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { userId } = req.body;

    const stream = await Stream.findOne({ streamId });
    if (!stream || stream.streamerId.toString() !== req.user._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    await Stream.updateOne({ streamId }, { $pull: { coHosts: userId } });

    res.json({ success: true, message: 'Co-host removed' });
  } catch (error) {
    next(error);
  }
};

exports.getUserStreams = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const { page = 1, pageSize = 20 } = req.query;

    const User = require('../models/User');
    const targetUser = await User.findOne({ userId });
    if (!targetUser) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    const query = { streamerId: targetUser._id };
    if (!req.user || req.user.userId !== userId) {
      query.status = { $in: ['live', 'ended'] };
      query.isHidden = false;
    }

    const [streams, total] = await Promise.all([
      Stream.find(query)
        .sort({ createdAt: -1 })
        .skip((page - 1) * pageSize)
        .limit(parseInt(pageSize))
        .lean(),
      Stream.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: {
        items: streams,
        total,
        page: parseInt(page),
        pageSize: parseInt(pageSize),
        hasMore: page * pageSize < total,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.scheduleStream = async (req, res, next) => {
  try {
    const { title, category, scheduledAt, description, thumbnail } = req.body;

    const stream = new Stream({
      streamId: require('uuid').v4(),
      streamerId: req.user._id,
      title,
      description,
      category,
      thumbnail,
      agora: { channelName: '', token: '', uid: 0 },
      status: 'scheduled',
      scheduledAt: new Date(scheduledAt),
    });

    await stream.save();
    res.status(201).json({ success: true, data: stream });
  } catch (error) {
    next(error);
  }
};

exports.startRecording = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    await Stream.updateOne({ streamId }, { 'settings.recordingEnabled': true });
    res.json({ success: true, message: 'Recording started' });
  } catch (error) {
    next(error);
  }
};

exports.stopRecording = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    await Stream.updateOne({ streamId }, { 'settings.recordingEnabled': false });
    res.json({ success: true, message: 'Recording stopped' });
  } catch (error) {
    next(error);
  }
};

exports.moderateUser = async (req, res, next) => {
  try {
    const { streamId } = req.params;
    const { userId, action, reason } = req.body;

    const stream = await Stream.findOne({ streamId });
    if (!stream) return res.status(404).json({ success: false, message: 'Stream not found' });

    const isAuthorized = stream.streamerId.toString() === req.user._id.toString() ||
      stream.moderators.some(id => id.toString() === req.user._id.toString());

    if (!isAuthorized) {
      return res.status(403).json({ success: false, message: 'Not authorized' });
    }

    if (action === 'ban') {
      await Stream.updateOne({ streamId }, { $addToSet: { blockedUsers: userId } });
    } else if (action === 'unban') {
      await Stream.updateOne({ streamId }, { $pull: { blockedUsers: userId } });
    }

    res.json({ success: true, message: `User ${action}ned` });
  } catch (error) {
    next(error);
  }
};
