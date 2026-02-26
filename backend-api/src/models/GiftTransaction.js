const mongoose = require('mongoose');

const giftTransactionSchema = new mongoose.Schema({
  transactionId: { type: String, required: true, unique: true, index: true },
  senderId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  receiverId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, index: true },
  giftId: { type: mongoose.Schema.Types.ObjectId, ref: 'Gift', required: true },
  streamId: { type: String, index: true },
  roomId: { type: String },
  quantity: { type: Number, required: true, min: 1, default: 1 },
  coinCost: { type: Number, required: true },
  diamondsEarned: { type: Number, required: true },
  platformFee: { type: Number, default: 0 },
  netDiamonds: { type: Number, required: true },
  message: { type: String, maxlength: 100 },
  isAnonymous: { type: Boolean, default: false },
  isSuperChat: { type: Boolean, default: false },
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'refunded'],
    default: 'completed',
    index: true,
  },
}, {
  timestamps: true,
});

giftTransactionSchema.index({ senderId: 1, createdAt: -1 });
giftTransactionSchema.index({ receiverId: 1, createdAt: -1 });
giftTransactionSchema.index({ streamId: 1, createdAt: -1 });

module.exports = mongoose.model('GiftTransaction', giftTransactionSchema);
