const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  userId: {
    type: String,
    required: true,
    unique: true,
    index: true,
  },
  username: {
    type: String,
    required: true,
    unique: true,
    lowercase: true,
    trim: true,
    minlength: 3,
    maxlength: 30,
    match: /^[a-zA-Z0-9_]+$/,
  },
  email: {
    type: String,
    unique: true,
    sparse: true,
    lowercase: true,
    trim: true,
  },
  phone: {
    type: String,
    unique: true,
    sparse: true,
    trim: true,
  },
  passwordHash: {
    type: String,
    select: false,
  },
  profile: {
    avatar: { type: String, default: null },
    coverImage: { type: String, default: null },
    displayName: { type: String, required: true, trim: true, maxlength: 50 },
    bio: { type: String, trim: true, maxlength: 150 },
    birthday: { type: Date },
    gender: { type: String, enum: ['male', 'female', 'other', 'prefer_not_to_say'] },
    country: { type: String },
    city: { type: String },
    verified: { type: Boolean, default: false },
    level: { type: Number, default: 1, min: 1 },
    xp: { type: Number, default: 0, min: 0 },
  },
  socialLinks: {
    instagram: String,
    youtube: String,
    tiktok: String,
    twitter: String,
  },
  stats: {
    followers: { type: Number, default: 0, min: 0 },
    following: { type: Number, default: 0, min: 0 },
    totalViews: { type: Number, default: 0, min: 0 },
    totalGiftsReceived: { type: Number, default: 0, min: 0 },
    totalGiftsSent: { type: Number, default: 0, min: 0 },
    totalStreams: { type: Number, default: 0, min: 0 },
    totalStreamDuration: { type: Number, default: 0, min: 0 },
  },
  subscription: {
    plan: { type: String, enum: ['free', 'premium', 'vip'], default: 'free' },
    startDate: Date,
    endDate: Date,
    stripeSubscriptionId: String,
    isActive: { type: Boolean, default: false },
    autoRenew: { type: Boolean, default: true },
  },
  wallet: {
    coins: { type: Number, default: 0, min: 0 },
    diamonds: { type: Number, default: 0, min: 0 },
    earnings: { type: Number, default: 0, min: 0 },
  },
  settings: {
    notifications: {
      followNotifications: { type: Boolean, default: true },
      giftNotifications: { type: Boolean, default: true },
      commentNotifications: { type: Boolean, default: true },
      streamStartNotifications: { type: Boolean, default: true },
      systemNotifications: { type: Boolean, default: true },
      promotionNotifications: { type: Boolean, default: true },
      soundEnabled: { type: Boolean, default: true },
      vibrationEnabled: { type: Boolean, default: true },
    },
    privacy: {
      profileVisibility: { type: String, enum: ['public', 'followers', 'private'], default: 'public' },
      showFollowersCount: { type: Boolean, default: true },
      showFollowingCount: { type: Boolean, default: true },
      allowDirectMessages: { type: String, enum: ['everyone', 'followers', 'none'], default: 'everyone' },
      allowGiftsFromStranger: { type: Boolean, default: true },
      showOnlineStatus: { type: Boolean, default: true },
    },
    theme: { type: String, enum: ['light', 'dark', 'auto'], default: 'dark' },
    language: { type: String, default: 'en' },
  },
  moderation: {
    isBanned: { type: Boolean, default: false },
    banReason: String,
    banUntil: Date,
    isPermanentBan: { type: Boolean, default: false },
    warnings: [{
      reason: String,
      issuedAt: { type: Date, default: Date.now },
      issuedBy: String,
    }],
    isVerified: { type: Boolean, default: false },
    isContentCreator: { type: Boolean, default: false },
    shadowBanned: { type: Boolean, default: false },
  },
  auth: {
    providers: [{ type: String, enum: ['email', 'google', 'facebook', 'apple', 'phone'] }],
    twoFactorEnabled: { type: Boolean, default: false },
    twoFactorSecret: { type: String, select: false },
    refreshTokens: [{ type: String, select: false }],
    fcmToken: { type: String, select: false },
    emailVerified: { type: Boolean, default: false },
    emailVerificationToken: { type: String, select: false },
    phoneVerified: { type: Boolean, default: false },
    lastLogin: Date,
    loginCount: { type: Number, default: 0 },
    passwordChangedAt: Date,
    passwordResetToken: { type: String, select: false },
    passwordResetExpires: { type: Date, select: false },
  },
  isActive: { type: Boolean, default: true },
  deletedAt: { type: Date, default: null },
}, {
  timestamps: true,
  toJSON: { virtuals: true },
  toObject: { virtuals: true },
});

userSchema.index({ 'profile.displayName': 'text', username: 'text' });
userSchema.index({ 'profile.country': 1 });
userSchema.index({ 'stats.followers': -1 });
userSchema.index({ createdAt: -1 });
userSchema.index({ 'auth.fcmToken': 1 }, { sparse: true });

userSchema.virtual('isSubscribed').get(function () {
  return this.subscription.isActive &&
    this.subscription.endDate > new Date();
});

userSchema.virtual('isLeveledUp').get(function () {
  return this.profile.xp >= this.profile.level * 1000;
});

userSchema.methods.comparePassword = async function (candidatePassword) {
  if (!this.passwordHash) return false;
  return bcrypt.compare(candidatePassword, this.passwordHash);
};

userSchema.methods.setPassword = async function (password) {
  this.passwordHash = await bcrypt.hash(password, 12);
};

userSchema.methods.addXP = function (amount) {
  this.profile.xp += amount;
  const requiredXP = this.profile.level * 1000;
  while (this.profile.xp >= requiredXP) {
    this.profile.xp -= requiredXP;
    this.profile.level += 1;
  }
};

userSchema.pre('save', function (next) {
  if (this.moderation.isBanned && !this.moderation.banUntil) {
    this.moderation.isPermanentBan = true;
  }
  next();
});

userSchema.statics.findByEmailOrUsername = function (identifier) {
  return this.findOne({
    $or: [
      { email: identifier.toLowerCase() },
      { username: identifier.toLowerCase() },
    ],
    deletedAt: null,
    isActive: true,
  }).select('+passwordHash +auth.refreshTokens +auth.twoFactorSecret +auth.fcmToken');
};

const User = mongoose.model('User', userSchema);

module.exports = User;
