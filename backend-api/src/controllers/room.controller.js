const Room = require('../models/Room');
const User = require('../models/User');
const { v4: uuidv4 } = require('uuid');
const { deleteCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.createRoom = async (req, res, next) => {
  try {
    const { title, description, category, type = 'voice', settings } = req.body;

    if (!title || !category) {
      return res.status(400).json({ success: false, message: 'Title and category are required' });
    }

    const activeRoom = await Room.findOne({ ownerId: req.user._id, status: 'active' }).lean();
    if (activeRoom) {
      return res.status(409).json({ success: false, message: 'You already have an active room', data: activeRoom });
    }

    const roomId = uuidv4();
    const channelName = `room_${roomId.replace(/-/g, '').substring(0, 16)}`;

    const room = await Room.create({
      roomId,
      ownerId: req.user._id,
      title: title.trim(),
      description: description?.trim(),
      category,
      type,
      settings: settings || {},
      agora: { channelName },
      speakers: [{ userId: req.user._id, joinedAt: new Date(), isMuted: false }],
      participants: [req.user._id],
      stats: { currentParticipants: 1 },
    });

    await room.populate('ownerId', 'userId username profile.displayName profile.avatar profile.verified');

    res.status(201).json({ success: true, data: room, message: 'Room created successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getRooms = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { category, type } = req.query;

    const query = { status: 'active' };
    if (category) query.category = category;
    if (type) query.type = type;

    const [rooms, total] = await Promise.all([
      Room.find(query)
        .sort({ 'stats.currentParticipants': -1, createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('ownerId', 'userId username profile.displayName profile.avatar profile.verified')
        .select('-speakers.userId -participants -moderators -agora.token')
        .lean(),
      Room.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: rooms,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.getRoom = async (req, res, next) => {
  try {
    const { roomId } = req.params;

    const room = await Room.findOne({ roomId })
      .populate('ownerId', 'userId username profile.displayName profile.avatar profile.verified profile.level')
      .populate('speakers.userId', 'userId username profile.displayName profile.avatar profile.level')
      .lean();

    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found' });
    }

    res.json({ success: true, data: room });
  } catch (error) {
    next(error);
  }
};

exports.joinRoom = async (req, res, next) => {
  try {
    const { roomId } = req.params;

    const room = await Room.findOne({ roomId, status: 'active' });
    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found or has ended' });
    }

    if (!room.participants.includes(req.user._id)) {
      room.participants.push(req.user._id);
      room.stats.currentParticipants += 1;
      room.stats.totalParticipants += 1;
      if (room.stats.currentParticipants > room.stats.peakParticipants) {
        room.stats.peakParticipants = room.stats.currentParticipants;
      }
      await room.save();
    }

    res.json({ success: true, data: { roomId, channelName: room.agora.channelName }, message: 'Joined room' });
  } catch (error) {
    next(error);
  }
};

exports.leaveRoom = async (req, res, next) => {
  try {
    const { roomId } = req.params;

    await Room.findOneAndUpdate(
      { roomId },
      {
        $pull: {
          participants: req.user._id,
          speakers: { userId: req.user._id },
        },
        $inc: { 'stats.currentParticipants': -1 },
      }
    );

    res.json({ success: true, message: 'Left room' });
  } catch (error) {
    next(error);
  }
};

exports.endRoom = async (req, res, next) => {
  try {
    const { roomId } = req.params;

    const room = await Room.findOne({ roomId, ownerId: req.user._id });
    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found or unauthorized' });
    }

    room.status = 'ended';
    room.endedAt = new Date();
    room.stats.duration = Math.floor((room.endedAt - room.startedAt) / 1000);
    await room.save();

    res.json({ success: true, message: 'Room ended' });
  } catch (error) {
    next(error);
  }
};

exports.requestSpeaker = async (req, res, next) => {
  try {
    const { roomId } = req.params;

    const room = await Room.findOne({ roomId, status: 'active' });
    if (!room) {
      return res.status(404).json({ success: false, message: 'Room not found' });
    }

    const currentSpeakers = room.speakers.filter(s => s.userId);
    if (currentSpeakers.length >= room.settings.maxSpeakers) {
      return res.status(400).json({ success: false, message: 'Speaker slots are full' });
    }

    const alreadySpeaker = room.speakers.some(s => s.userId?.toString() === req.user._id.toString());
    if (alreadySpeaker) {
      return res.status(409).json({ success: false, message: 'Already a speaker' });
    }

    room.speakers.push({ userId: req.user._id, joinedAt: new Date(), isMuted: false });
    await room.save();

    res.json({ success: true, message: 'Speaker request granted' });
  } catch (error) {
    next(error);
  }
};
