const mongoose = require('mongoose');

const musicSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true },
  artist: { type: String, required: true, trim: true },
  album: { type: String, trim: true },
  genre: {
    type: String,
    enum: ['pop', 'hip_hop', 'rnb', 'edm', 'rock', 'jazz', 'classical', 'lofi', 'other'],
    required: true,
    index: true,
  },
  coverUrl: { type: String },
  audioUrl: { type: String, required: true },
  previewUrl: { type: String },
  duration: { type: Number, required: true },
  bpm: { type: Number },
  isLicensed: { type: Boolean, default: true },
  licenseType: { type: String, enum: ['free', 'premium', 'exclusive'], default: 'free' },
  isActive: { type: Boolean, default: true, index: true },
  playCount: { type: Number, default: 0 },
  tags: [{ type: String, lowercase: true }],
  mood: {
    type: String,
    enum: ['happy', 'sad', 'energetic', 'calm', 'romantic', 'motivational'],
  },
}, {
  timestamps: true,
});

musicSchema.index({ genre: 1, isActive: 1 });
musicSchema.index({ playCount: -1 });
musicSchema.index({ title: 'text', artist: 'text' });

module.exports = mongoose.model('Music', musicSchema);
