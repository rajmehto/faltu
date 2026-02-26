const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
  eventId: { type: String, required: true, unique: true, index: true },
  creatorId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  title: { type: String, required: true, trim: true, maxlength: 80 },
  description: { type: String, trim: true, maxlength: 1000 },
  coverImage: { type: String },
  category: { type: String, required: true, index: true },
  type: {
    type: String,
    enum: ['live_event', 'tournament', 'challenge', 'concert', 'meetup'],
    default: 'live_event',
  },
  scheduledAt: { type: Date, required: true, index: true },
  endAt: { type: Date },
  timezone: { type: String, default: 'UTC' },
  prizes: [{
    rank: { type: Number, required: true },
    description: { type: String },
    coins: { type: Number, default: 0 },
    diamonds: { type: Number, default: 0 },
    badge: { type: String },
  }],
  rsvps: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  rsvpCount: { type: Number, default: 0 },
  maxParticipants: { type: Number },
  streamId: { type: String },
  isPublic: { type: Boolean, default: true },
  isFeatured: { type: Boolean, default: false },
  status: {
    type: String,
    enum: ['upcoming', 'live', 'ended', 'cancelled'],
    default: 'upcoming',
    index: true,
  },
  tags: [{ type: String, lowercase: true }],
  notificationSent: { type: Boolean, default: false },
}, {
  timestamps: true,
});

eventSchema.index({ scheduledAt: 1, status: 1 });
eventSchema.index({ isFeatured: 1, status: 1 });
eventSchema.index({ title: 'text', description: 'text' });

module.exports = mongoose.model('Event', eventSchema);
