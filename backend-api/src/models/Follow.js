const mongoose = require('mongoose');

const followSchema = new mongoose.Schema({
  followerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  followingId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  notificationsEnabled: { type: Boolean, default: true },
}, {
  timestamps: true,
});

followSchema.index({ followerId: 1, followingId: 1 }, { unique: true });
followSchema.index({ followingId: 1, createdAt: -1 });
followSchema.index({ followerId: 1, createdAt: -1 });

module.exports = mongoose.model('Follow', followSchema);
