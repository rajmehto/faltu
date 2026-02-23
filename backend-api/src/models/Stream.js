const mongoose = require('mongoose');

const streamSchema = new mongoose.Schema({
  streamId: { type: String, required: true, unique: true, index: true },
  streamerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  title: { type: String, required: true, trim: true, maxlength: 80 },
  description: { type: String, trim: true, maxlength: 500 },
  thumbnail: { type: String },
  category: { type: String, required: true, index: true },
  tags: [{ type: String, lowercase: true, trim: true }],
  settings: {
    privacy: { type: String, enum: ['public', 'private', 'followers_only', 'password_protected'], default: 'public' },
    password: { type: String, select: false },
    allowGuests: { type: Boolean, default: true },
    maxViewers: { type: Number },
    coHostEnabled: { type: Boolean, default: true },
    recordingEnabled: { type: Boolean, default: false },
    multiStreamEnabled: { type: Boolean, default: false },
    chatEnabled: { type: Boolean, default: true },
    giftsEnabled: { type: Boolean, default: true },
    backgroundMusicEnabled: { type: Boolean, default: false },
    slowMode: { type: Boolean, default: false },
    slowModeInterval: { type: Number, default: 10 },
    subscriptionOnly: { type: Boolean, default: false },
    minimumLevel: { type: Number, default: 1 },
  },
  agora: {
    channelName: { type: String, required: true },
    token: { type: String },
    uid: { type: Number },
    appId: { type: String },
    recordingSid: { type: String },
  },
  rtmp: {
    streamKey: { type: String, select: false },
    pushUrl: { type: String, select: false },
    playUrl: { type: String },
  },
  stats: {
    currentViewers: { type: Number, default: 0, min: 0 },
    peakViewers: { type: Number, default: 0, min: 0 },
    totalViews: { type: Number, default: 0, min: 0 },
    uniqueViewers: { type: Number, default: 0, min: 0 },
    duration: { type: Number, default: 0, min: 0 },
    likes: { type: Number, default: 0, min: 0 },
    shares: { type: Number, default: 0, min: 0 },
    comments: { type: Number, default: 0, min: 0 },
    avgWatchTime: { type: Number, default: 0, min: 0 },
  },
  monetization: {
    giftsReceived: { type: Number, default: 0, min: 0 },
    totalValue: { type: Number, default: 0, min: 0 },
    diamondsEarned: { type: Number, default: 0, min: 0 },
    superChats: { type: Number, default: 0, min: 0 },
    superChatValue: { type: Number, default: 0, min: 0 },
  },
  status: {
    type: String,
    enum: ['scheduled', 'live', 'ended', 'replay', 'cancelled'],
    default: 'live',
    index: true,
  },
  scheduledAt: { type: Date },
  startedAt: { type: Date },
  endedAt: { type: Date },
  recordings: [{
    url: { type: String, required: true },
    duration: { type: Number, default: 0 },
    thumbnail: { type: String },
    fileSize: { type: Number },
    format: { type: String, default: 'mp4' },
    quality: { type: String, enum: ['360p', '720p', '1080p'], default: '720p' },
    createdAt: { type: Date, default: Date.now },
  }],
  highlights: [{
    url: String,
    timestamp: Number,
    thumbnailUrl: String,
    description: String,
    viewCount: { type: Number, default: 0 },
    createdAt: { type: Date, default: Date.now },
  }],
  coHosts: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  moderators: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  blockedUsers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  activeViewers: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  pinnedMessage: { type: mongoose.Schema.Types.ObjectId, ref: 'ChatMessage' },
  location: {
    type: { type: String, enum: ['Point'] },
    coordinates: [Number],
    city: String,
    country: String,
  },
  backgroundMusic: {
    musicId: { type: mongoose.Schema.Types.ObjectId, ref: 'Music' },
    title: String,
    artist: String,
    audioUrl: String,
    startedAt: Date,
  },
  aiModeration: {
    contentSafe: { type: Boolean, default: true },
    nsfwScore: { type: Number, default: 0 },
    lastCheckedAt: Date,
    autoTerminated: { type: Boolean, default: false },
    terminationReason: String,
  },
  reportCount: { type: Number, default: 0 },
  isHidden: { type: Boolean, default: false },
  isFeatured: { type: Boolean, default: false },
  featuredAt: Date,
  trendingScore: { type: Number, default: 0 },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

streamSchema.index({ status: 1, createdAt: -1 });
streamSchema.index({ streamerId: 1, status: 1 });
streamSchema.index({ category: 1, status: 1 });
streamSchema.index({ trendingScore: -1 });
streamSchema.index({ location: '2dsphere' }, { sparse: true });
streamSchema.index({ title: 'text', description: 'text', tags: 'text' });
streamSchema.index({ 'stats.currentViewers': -1, status: 1 });

streamSchema.virtual('isLive').get(function () {
  return this.status === 'live';
});

streamSchema.virtual('streamDuration').get(function () {
  if (!this.startedAt) return 0;
  const end = this.endedAt || new Date();
  return Math.floor((end - this.startedAt) / 1000);
});

streamSchema.methods.updateTrendingScore = function () {
  const timeFactor = Math.max(0, 1 - (Date.now() - this.startedAt) / (4 * 60 * 60 * 1000));
  this.trendingScore =
    (this.stats.currentViewers * 3 +
      this.stats.likes * 2 +
      this.monetization.totalValue * 0.1 +
      this.stats.shares * 5) *
    (1 + timeFactor);
};

const Stream = mongoose.model('Stream', streamSchema);

module.exports = Stream;
