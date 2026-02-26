const mongoose = require('mongoose');

const giftSchema = new mongoose.Schema({
  name: { type: String, required: true, trim: true },
  description: { type: String, trim: true, maxlength: 200 },
  imageUrl: { type: String, required: true },
  animationUrl: { type: String },
  thumbnailUrl: { type: String },
  category: {
    type: String,
    enum: ['popular', 'luxury', 'cute', 'funny', 'special', 'seasonal', 'love', 'sport'],
    required: true,
    index: true,
  },
  coinPrice: { type: Number, required: true, min: 1 },
  diamondValue: { type: Number, required: true, min: 0 },
  animationDuration: { type: Number, default: 3000 },
  hasFullScreenAnimation: { type: Boolean, default: false },
  isLimited: { type: Boolean, default: false },
  availableFrom: { type: Date },
  availableUntil: { type: Date },
  isActive: { type: Boolean, default: true, index: true },
  sortOrder: { type: Number, default: 0 },
  totalSent: { type: Number, default: 0 },
}, {
  timestamps: true,
});

giftSchema.index({ category: 1, isActive: 1, sortOrder: 1 });
giftSchema.index({ coinPrice: 1 });
giftSchema.index({ totalSent: -1 });

module.exports = mongoose.model('Gift', giftSchema);
