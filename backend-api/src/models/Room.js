const mongoose = require('mongoose');

const roomSchema = new mongoose.Schema({
  roomId: { type: String, required: true, unique: true, index: true },
  ownerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  title: { type: String, required: true, trim: true, maxlength: 80 },
  description: { type: String, trim: true, maxlength: 300 },
  coverImage: { type: String },
  category: { type: String, required: true, index: true },
  type: {
    type: String,
    enum: ['voice', 'party', 'gaming', 'music', 'talk'],
    default: 'voice',
  },
  settings: {
    maxSpeakers: { type: Number, default: 9, max: 9 },
    maxParticipants: { type: Number, default: 100 },
    isLocked: { type: Boolean, default: false },
    password: { type: String, select: false },
    guestsAllowed: { type: Boolean, default: true },
    giftsEnabled: { type: Boolean, default: true },
    subscriptionOnly: { type: Boolean, default: false },
  },
  speakers: [{
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    joinedAt: { type: Date, default: Date.now },
    isMuted: { type: Boolean, default: false },
  }],
  participants: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  moderators: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  stats: {
    currentParticipants: { type: Number, default: 0 },
    peakParticipants: { type: Number, default: 0 },
    totalParticipants: { type: Number, default: 0 },
    duration: { type: Number, default: 0 },
    giftsReceived: { type: Number, default: 0 },
  },
  agora: {
    channelName: { type: String, required: true },
    token: { type: String },
  },
  status: {
    type: String,
    enum: ['active', 'ended'],
    default: 'active',
    index: true,
  },
  startedAt: { type: Date, default: Date.now },
  endedAt: { type: Date },
  trendingScore: { type: Number, default: 0 },
}, {
  timestamps: true,
});

roomSchema.index({ status: 1, trendingScore: -1 });
roomSchema.index({ ownerId: 1, status: 1 });
roomSchema.index({ category: 1, status: 1 });

module.exports = mongoose.model('Room', roomSchema);
