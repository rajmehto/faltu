const mongoose = require('mongoose');

const achievementSchema = new mongoose.Schema({
  key: { type: String, required: true, unique: true, index: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  iconUrl: { type: String },
  category: {
    type: String,
    enum: ['streaming', 'social', 'gifting', 'watching', 'special', 'milestone'],
    required: true,
    index: true,
  },
  rarity: {
    type: String,
    enum: ['common', 'uncommon', 'rare', 'epic', 'legendary'],
    default: 'common',
  },
  condition: {
    metric: { type: String, required: true },
    threshold: { type: Number, required: true },
  },
  rewards: {
    xp: { type: Number, default: 0 },
    coins: { type: Number, default: 0 },
    diamonds: { type: Number, default: 0 },
    badge: { type: String },
  },
  isHidden: { type: Boolean, default: false },
  isActive: { type: Boolean, default: true },
  sortOrder: { type: Number, default: 0 },
}, {
  timestamps: true,
});

const userAchievementSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  achievementKey: { type: String, required: true, index: true },
  progress: { type: Number, default: 0 },
  isUnlocked: { type: Boolean, default: false, index: true },
  unlockedAt: { type: Date },
  isNotified: { type: Boolean, default: false },
}, {
  timestamps: true,
});

userAchievementSchema.index({ userId: 1, achievementKey: 1 }, { unique: true });

const Achievement = mongoose.model('Achievement', achievementSchema);
const UserAchievement = mongoose.model('UserAchievement', userAchievementSchema);

module.exports = { Achievement, UserAchievement };
