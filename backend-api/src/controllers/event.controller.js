const Event = require('../models/Event');
const User = require('../models/User');
const Notification = require('../models/Notification');
const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');

exports.createEvent = async (req, res, next) => {
  try {
    const { title, description, category, type, scheduledAt, endAt, prizes, maxParticipants, tags } = req.body;

    if (!title || !category || !scheduledAt) {
      return res.status(400).json({ success: false, message: 'Title, category, and scheduledAt are required' });
    }

    const scheduled = new Date(scheduledAt);
    if (scheduled <= new Date()) {
      return res.status(400).json({ success: false, message: 'Event must be scheduled in the future' });
    }

    const event = await Event.create({
      eventId: uuidv4(),
      creatorId: req.user._id,
      title: title.trim(),
      description: description?.trim(),
      category,
      type: type || 'live_event',
      scheduledAt: scheduled,
      endAt: endAt ? new Date(endAt) : null,
      prizes: prizes || [],
      maxParticipants,
      tags: tags || [],
      isPublic: true,
    });

    await event.populate('creatorId', 'userId username profile.displayName profile.avatar');

    res.status(201).json({ success: true, data: event, message: 'Event created successfully' });
  } catch (error) {
    next(error);
  }
};

exports.getEvents = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { category, status = 'upcoming', featured } = req.query;

    const query = { isPublic: true, status };
    if (category) query.category = category;
    if (featured === 'true') query.isFeatured = true;

    const sortOptions = status === 'upcoming'
      ? { scheduledAt: 1 }
      : { scheduledAt: -1 };

    const [events, total] = await Promise.all([
      Event.find(query)
        .sort(sortOptions)
        .skip(skip)
        .limit(limit)
        .populate('creatorId', 'userId username profile.displayName profile.avatar profile.verified')
        .select('-rsvps')
        .lean(),
      Event.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: events,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.getEvent = async (req, res, next) => {
  try {
    const { eventId } = req.params;

    const event = await Event.findOne({ eventId })
      .populate('creatorId', 'userId username profile.displayName profile.avatar profile.verified')
      .lean();

    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found' });
    }

    let isRsvped = false;
    if (req.user) {
      isRsvped = event.rsvps?.some(id => id.toString() === req.user._id.toString());
    }

    res.json({ success: true, data: { ...event, isRsvped } });
  } catch (error) {
    next(error);
  }
};

exports.rsvpEvent = async (req, res, next) => {
  try {
    const { eventId } = req.params;

    const event = await Event.findOne({ eventId, status: 'upcoming' });
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found or already started' });
    }

    if (event.maxParticipants && event.rsvpCount >= event.maxParticipants) {
      return res.status(400).json({ success: false, message: 'Event is at full capacity' });
    }

    const alreadyRsvped = event.rsvps.includes(req.user._id);

    if (alreadyRsvped) {
      event.rsvps.pull(req.user._id);
      event.rsvpCount = Math.max(0, event.rsvpCount - 1);
      await event.save();
      return res.json({ success: true, message: 'RSVP cancelled', isRsvped: false });
    }

    event.rsvps.push(req.user._id);
    event.rsvpCount += 1;
    await event.save();

    res.json({ success: true, message: 'RSVP confirmed', isRsvped: true });
  } catch (error) {
    next(error);
  }
};

exports.updateEvent = async (req, res, next) => {
  try {
    const { eventId } = req.params;

    const event = await Event.findOne({ eventId, creatorId: req.user._id });
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found or unauthorized' });
    }

    if (event.status !== 'upcoming') {
      return res.status(400).json({ success: false, message: 'Cannot update a started or ended event' });
    }

    const allowedUpdates = ['title', 'description', 'scheduledAt', 'endAt', 'coverImage', 'prizes', 'maxParticipants', 'tags'];
    for (const field of allowedUpdates) {
      if (req.body[field] !== undefined) {
        event[field] = req.body[field];
      }
    }

    await event.save();
    await event.populate('creatorId', 'userId username profile.displayName profile.avatar');

    res.json({ success: true, data: event, message: 'Event updated' });
  } catch (error) {
    next(error);
  }
};

exports.cancelEvent = async (req, res, next) => {
  try {
    const { eventId } = req.params;

    const event = await Event.findOne({ eventId, creatorId: req.user._id });
    if (!event) {
      return res.status(404).json({ success: false, message: 'Event not found or unauthorized' });
    }

    event.status = 'cancelled';
    await event.save();

    res.json({ success: true, message: 'Event cancelled' });
  } catch (error) {
    next(error);
  }
};

exports.getFeaturedEvents = async (req, res, next) => {
  try {
    const events = await Event.find({
      isFeatured: true,
      status: 'upcoming',
      isPublic: true,
    })
      .sort({ scheduledAt: 1 })
      .limit(10)
      .populate('creatorId', 'userId username profile.displayName profile.avatar profile.verified')
      .select('-rsvps')
      .lean();

    res.json({ success: true, data: events });
  } catch (error) {
    next(error);
  }
};
