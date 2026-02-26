const mongoose = require('mongoose');

const reportSchema = new mongoose.Schema({
  reporterId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  targetType: {
    type: String,
    enum: ['user', 'stream', 'message', 'room', 'event'],
    required: true,
    index: true,
  },
  targetId: { type: String, required: true, index: true },
  reason: {
    type: String,
    enum: ['spam', 'harassment', 'nsfw', 'violence', 'hate_speech', 'misinformation', 'copyright', 'other'],
    required: true,
  },
  description: { type: String, maxlength: 500 },
  screenshotUrls: [{ type: String }],
  status: {
    type: String,
    enum: ['pending', 'reviewing', 'resolved', 'dismissed'],
    default: 'pending',
    index: true,
  },
  reviewedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  reviewedAt: { type: Date },
  resolution: { type: String, maxlength: 300 },
  actionTaken: {
    type: String,
    enum: ['none', 'warning', 'content_removed', 'user_banned', 'user_suspended'],
  },
}, {
  timestamps: true,
});

reportSchema.index({ status: 1, createdAt: -1 });
reportSchema.index({ reporterId: 1, targetId: 1, targetType: 1 });

module.exports = mongoose.model('Report', reportSchema);
