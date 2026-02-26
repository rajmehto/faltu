const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipientId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  type: {
    type: String,
    enum: [
      'follow', 'unfollow', 'gift', 'stream_start', 'stream_end',
      'mention', 'comment', 'like', 'super_chat', 'achievement',
      'level_up', 'system', 'promotion', 'purchase_success', 'withdrawal',
    ],
    required: true,
    index: true,
  },
  title: { type: String, required: true, maxlength: 100 },
  body: { type: String, required: true, maxlength: 300 },
  imageUrl: { type: String },
  data: { type: mongoose.Schema.Types.Mixed },
  isRead: { type: Boolean, default: false, index: true },
  readAt: { type: Date },
  isSent: { type: Boolean, default: false },
  sentAt: { type: Date },
  expiresAt: { type: Date },
}, {
  timestamps: true,
});

notificationSchema.index({ recipientId: 1, isRead: 1, createdAt: -1 });
notificationSchema.index({ recipientId: 1, createdAt: -1 });
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

module.exports = mongoose.model('Notification', notificationSchema);
