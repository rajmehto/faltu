const Notification = require('../models/Notification');
const User = require('../models/User');
const logger = require('../utils/logger');

exports.getNotifications = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { unreadOnly } = req.query;

    const query = { recipientId: req.user._id };
    if (unreadOnly === 'true') query.isRead = false;

    const [notifications, total, unreadCount] = await Promise.all([
      Notification.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('senderId', 'userId username profile.displayName profile.avatar')
        .lean(),
      Notification.countDocuments(query),
      Notification.countDocuments({ recipientId: req.user._id, isRead: false }),
    ]);

    res.json({
      success: true,
      data: notifications,
      unreadCount,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};

exports.markAsRead = async (req, res, next) => {
  try {
    const { notificationId } = req.params;

    const notification = await Notification.findOne({
      _id: notificationId,
      recipientId: req.user._id,
    });

    if (!notification) {
      return res.status(404).json({ success: false, message: 'Notification not found' });
    }

    notification.isRead = true;
    notification.readAt = new Date();
    await notification.save();

    res.json({ success: true, message: 'Notification marked as read' });
  } catch (error) {
    next(error);
  }
};

exports.markAllAsRead = async (req, res, next) => {
  try {
    await Notification.updateMany(
      { recipientId: req.user._id, isRead: false },
      { $set: { isRead: true, readAt: new Date() } }
    );

    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (error) {
    next(error);
  }
};

exports.deleteNotification = async (req, res, next) => {
  try {
    const { notificationId } = req.params;

    await Notification.findOneAndDelete({
      _id: notificationId,
      recipientId: req.user._id,
    });

    res.json({ success: true, message: 'Notification deleted' });
  } catch (error) {
    next(error);
  }
};

exports.clearAll = async (req, res, next) => {
  try {
    await Notification.deleteMany({ recipientId: req.user._id });

    res.json({ success: true, message: 'All notifications cleared' });
  } catch (error) {
    next(error);
  }
};

exports.getUnreadCount = async (req, res, next) => {
  try {
    const count = await Notification.countDocuments({
      recipientId: req.user._id,
      isRead: false,
    });

    res.json({ success: true, data: { count } });
  } catch (error) {
    next(error);
  }
};
