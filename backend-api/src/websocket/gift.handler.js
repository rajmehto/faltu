const Gift = require('../models/Gift');
const GiftTransaction = require('../models/GiftTransaction');
const User = require('../models/User');
const Stream = require('../models/Stream');
const Notification = require('../models/Notification');
const { addToSortedSet } = require('../config/redis');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

module.exports = function (io, socket) {
  socket.on('gift:send', async (data) => {
    try {
      const { giftId, receiverId, streamId, quantity = 1, message, isAnonymous = false } = data;

      if (!socket.user) {
        return socket.emit('gift:error', { message: 'Authentication required' });
      }

      const [gift, receiver, sender] = await Promise.all([
        Gift.findById(giftId).lean(),
        User.findOne({ userId: receiverId, isActive: true }),
        User.findById(socket.user._id),
      ]);

      if (!gift || !gift.isActive) {
        return socket.emit('gift:error', { message: 'Gift not found' });
      }

      if (!receiver || !sender) {
        return socket.emit('gift:error', { message: 'User not found' });
      }

      const totalCost = gift.coinPrice * Math.min(quantity, 99);

      if (sender.wallet.coins < totalCost) {
        return socket.emit('gift:error', { message: 'Insufficient coins', code: 'INSUFFICIENT_COINS' });
      }

      const platformFee = Math.floor(gift.diamondValue * 0.3);
      const netDiamonds = (gift.diamondValue * quantity) - platformFee;

      const transaction = await GiftTransaction.create({
        transactionId: uuidv4(),
        senderId: sender._id,
        receiverId: receiver._id,
        giftId: gift._id,
        streamId,
        quantity,
        coinCost: totalCost,
        diamondsEarned: gift.diamondValue * quantity,
        platformFee,
        netDiamonds,
        message,
        isAnonymous,
        status: 'completed',
      });

      await Promise.all([
        User.findByIdAndUpdate(sender._id, {
          $inc: { 'wallet.coins': -totalCost, 'stats.totalGiftsSent': quantity },
        }),
        User.findByIdAndUpdate(receiver._id, {
          $inc: { 'wallet.diamonds': netDiamonds, 'wallet.earnings': netDiamonds, 'stats.totalGiftsReceived': quantity },
        }),
      ]);

      if (streamId) {
        await Stream.findOneAndUpdate({ streamId }, {
          $inc: {
            'monetization.giftsReceived': quantity,
            'monetization.totalValue': totalCost,
            'monetization.diamondsEarned': netDiamonds,
          },
        });
      }

      await Gift.findByIdAndUpdate(giftId, { $inc: { totalSent: quantity } });

      if (!isAnonymous) {
        await addToSortedSet('leaderboard:gifters:daily', totalCost, socket.user.userId);
        await addToSortedSet('leaderboard:gifters:weekly', totalCost, socket.user.userId);
      }

      const giftPayload = {
        transaction: { id: transaction._id, transactionId: transaction.transactionId },
        gift: { id: gift._id, name: gift.name, imageUrl: gift.imageUrl, animationUrl: gift.animationUrl, coinPrice: gift.coinPrice },
        sender: isAnonymous ? null : {
          userId: socket.user.userId,
          username: socket.user.username,
          displayName: socket.user.profile?.displayName,
          avatar: socket.user.profile?.avatar,
          level: socket.user.profile?.level,
        },
        receiver: { userId: receiver.userId, username: receiver.username },
        quantity,
        message,
        streamId,
      };

      if (streamId) {
        io.to(`stream:${streamId}`).emit(`gift:received:${streamId}`, giftPayload);
      }

      io.to(`user:${receiverId}`).emit('gift:received', giftPayload);
      socket.emit('gift:sent', { success: true, remainingCoins: sender.wallet.coins - totalCost });

      await Notification.create({
        recipientId: receiver._id,
        senderId: isAnonymous ? null : sender._id,
        type: 'gift',
        title: isAnonymous ? 'You received a gift!' : `${sender.profile?.displayName} sent you a gift!`,
        body: `You received ${quantity}x ${gift.name}`,
        data: { giftId: gift._id, transactionId: transaction.transactionId, streamId },
      });
    } catch (err) {
      logger.error('gift:send error', err);
      socket.emit('gift:error', { message: 'Failed to send gift' });
    }
  });

  socket.on('gift:super_chat', async (data) => {
    try {
      const { streamId, amount, message } = data;

      if (!socket.user) {
        return socket.emit('gift:error', { message: 'Authentication required' });
      }

      const sender = await User.findById(socket.user._id);
      if (sender.wallet.coins < amount) {
        return socket.emit('gift:error', { message: 'Insufficient coins', code: 'INSUFFICIENT_COINS' });
      }

      const stream = await Stream.findOne({ streamId, status: 'live' }).lean();
      if (!stream) return;

      await User.findByIdAndUpdate(sender._id, { $inc: { 'wallet.coins': -amount } });
      await Stream.findOneAndUpdate({ streamId }, {
        $inc: { 'monetization.superChats': 1, 'monetization.superChatValue': amount },
      });

      const superChatPayload = {
        type: 'super_chat',
        sender: { userId: socket.user.userId, displayName: socket.user.profile?.displayName, avatar: socket.user.profile?.avatar },
        amount,
        message,
        streamId,
      };

      io.to(`stream:${streamId}`).emit(`chat:super_chat:${streamId}`, superChatPayload);
      socket.emit('gift:super_chat:sent', { success: true, remainingCoins: sender.wallet.coins - amount });
    } catch (err) {
      logger.error('gift:super_chat error', err);
    }
  });
};
