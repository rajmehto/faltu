const mongoose = require('mongoose');

const chatMessageSchema = new mongoose.Schema({
  streamId: { type: String, required: true, index: true },
  roomId: { type: String, index: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  senderUsername: { type: String, required: true },
  senderDisplayName: { type: String, required: true },
  senderAvatar: { type: String },
  senderLevel: { type: Number, default: 1 },
  type: {
    type: String,
    enum: ['text', 'emoji', 'sticker', 'image', 'gift', 'super_chat', 'system'],
    default: 'text',
    index: true,
  },
  content: { type: String, required: true, maxlength: 500 },
  imageUrl: { type: String },
  stickerUrl: { type: String },
  replyTo: {
    messageId: { type: mongoose.Schema.Types.ObjectId },
    content: { type: String },
    senderUsername: { type: String },
  },
  reactions: [{
    emoji: { type: String, required: true },
    count: { type: Number, default: 1 },
    users: [{ type: mongoose.Schema.Types.ObjectId, ref: 'User' }],
  }],
  superChat: {
    amount: { type: Number },
    currency: { type: String, default: 'coins' },
    color: { type: String, default: '#FFD700' },
    durationSeconds: { type: Number, default: 30 },
  },
  isPinned: { type: Boolean, default: false },
  isDeleted: { type: Boolean, default: false },
  deletedAt: { type: Date },
  deletedBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  isMuted: { type: Boolean, default: false },
  isHighlighted: { type: Boolean, default: false },
}, {
  timestamps: true,
});

chatMessageSchema.index({ streamId: 1, createdAt: -1 });
chatMessageSchema.index({ roomId: 1, createdAt: -1 });
chatMessageSchema.index({ senderId: 1, createdAt: -1 });
chatMessageSchema.index({ isPinned: 1, streamId: 1 });

module.exports = mongoose.model('ChatMessage', chatMessageSchema);
