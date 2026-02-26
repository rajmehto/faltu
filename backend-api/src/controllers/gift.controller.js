const Gift = require('../models/Gift');
const GiftTransaction = require('../models/GiftTransaction');
const User = require('../models/User');
const Stream = require('../models/Stream');
const Notification = require('../models/Notification');
const { getFromCache, setCache, addToSortedSet } = require('../config/redis');
const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

exports.getGifts = async (req, res, next) => {
  try {
    const { category } = req.query;
    const cacheKey = `gifts:${category || 'all'}`;

    let gifts = await getFromCache(cacheKey);
    if (!gifts) {
      const query = { isActive: true };
      if (category) query.category = category;

      gifts = await Gift.find(query)
        .sort({ sortOrder: 1, coinPrice: 1 })
        .lean();

      await setCache(cacheKey, gifts, 600);
    }

    res.json({ success: true, data: gifts });
  } catch (error) {
    next(error);
  }
};

exports.sendGift = async (req, res, next) => {
  try {
    const { giftId, receiverId, streamId, quantity = 1, message, isAnonymous = false } = req.body;

    if (quantity < 1 || quantity > 99) {
      return res.status(400).json({ success: false, message: 'Quantity must be between 1 and 99' });
    }

    const [gift, receiver] = await Promise.all([
      Gift.findById(giftId).lean(),
      User.findOne({ userId: receiverId, isActive: true }),
    ]);

    if (!gift || !gift.isActive) {
      return res.status(404).json({ success: false, message: 'Gift not found' });
    }

    if (!receiver) {
      return res.status(404).json({ success: false, message: 'Receiver not found' });
    }

    if (receiver._id.toString() === req.user._id.toString()) {
      return res.status(400).json({ success: false, message: 'Cannot send gift to yourself' });
    }

    const totalCost = gift.coinPrice * quantity;

    const sender = await User.findById(req.user._id);
    if (sender.wallet.coins < totalCost) {
      return res.status(400).json({ success: false, message: 'Insufficient coins' });
    }

    const platformFee = Math.floor(gift.diamondValue * 0.3);
    const netDiamonds = (gift.diamondValue * quantity) - platformFee;

    const transaction = await GiftTransaction.create({
      transactionId: uuidv4(),
      senderId: req.user._id,
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
      User.findByIdAndUpdate(req.user._id, {
        $inc: {
          'wallet.coins': -totalCost,
          'stats.totalGiftsSent': quantity,
        },
      }),
      User.findByIdAndUpdate(receiver._id, {
        $inc: {
          'wallet.diamonds': netDiamonds,
          'wallet.earnings': netDiamonds,
          'stats.totalGiftsReceived': quantity,
        },
      }),
    ]);

    if (streamId) {
      await Stream.findOneAndUpdate(
        { streamId },
        {
          $inc: {
            'monetization.giftsReceived': quantity,
            'monetization.totalValue': totalCost,
            'monetization.diamondsEarned': netDiamonds,
          },
        }
      );
    }

    await Gift.findByIdAndUpdate(giftId, { $inc: { totalSent: quantity } });

    if (!isAnonymous) {
      await addToSortedSet(`leaderboard:gifters:daily`, totalCost, req.user.userId);
      await addToSortedSet(`leaderboard:gifters:weekly`, totalCost, req.user.userId);
      await addToSortedSet(`leaderboard:receivers:daily`, netDiamonds, receiver.userId);
    }

    await Notification.create({
      recipientId: receiver._id,
      senderId: isAnonymous ? null : req.user._id,
      type: 'gift',
      title: isAnonymous ? 'You received a gift!' : `${req.user.profile.displayName} sent you a gift!`,
      body: `You received ${quantity}x ${gift.name}`,
      data: { giftId: gift._id, transactionId: transaction.transactionId, streamId },
    });

    res.status(201).json({
      success: true,
      data: {
        transaction,
        gift,
        remainingCoins: sender.wallet.coins - totalCost,
      },
      message: 'Gift sent successfully',
    });
  } catch (error) {
    next(error);
  }
};

exports.getGiftLeaderboard = async (req, res, next) => {
  try {
    const { streamId, type = 'gifters', period = 'daily' } = req.query;
    const limit = parseInt(req.query.limit) || 10;

    let pipeline;
    const dateFilter = {};
    const now = new Date();

    if (period === 'daily') {
      dateFilter.$gte = new Date(now.setHours(0, 0, 0, 0));
    } else if (period === 'weekly') {
      const weekStart = new Date(now);
      weekStart.setDate(now.getDate() - now.getDay());
      weekStart.setHours(0, 0, 0, 0);
      dateFilter.$gte = weekStart;
    } else if (period === 'monthly') {
      dateFilter.$gte = new Date(now.getFullYear(), now.getMonth(), 1);
    }

    const matchQuery = { status: 'completed' };
    if (Object.keys(dateFilter).length > 0) matchQuery.createdAt = dateFilter;
    if (streamId) matchQuery.streamId = streamId;

    const groupField = type === 'gifters' ? '$senderId' : '$receiverId';
    const sumField = type === 'gifters' ? '$coinCost' : '$netDiamonds';

    pipeline = [
      { $match: matchQuery },
      { $group: { _id: groupField, total: { $sum: sumField }, count: { $sum: '$quantity' } } },
      { $sort: { total: -1 } },
      { $limit: limit },
      {
        $lookup: {
          from: 'users',
          localField: '_id',
          foreignField: '_id',
          as: 'user',
        },
      },
      { $unwind: '$user' },
      {
        $project: {
          total: 1,
          count: 1,
          'user.userId': 1,
          'user.username': 1,
          'user.profile.displayName': 1,
          'user.profile.avatar': 1,
          'user.profile.level': 1,
        },
      },
    ];

    const leaderboard = await GiftTransaction.aggregate(pipeline);

    res.json({ success: true, data: leaderboard });
  } catch (error) {
    next(error);
  }
};

exports.getGiftHistory = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;
    const { type = 'sent' } = req.query;

    const query = type === 'sent'
      ? { senderId: req.user._id }
      : { receiverId: req.user._id };

    const [transactions, total] = await Promise.all([
      GiftTransaction.find(query)
        .sort({ createdAt: -1 })
        .skip(skip)
        .limit(limit)
        .populate('giftId', 'name imageUrl coinPrice diamondValue category')
        .populate(type === 'sent' ? 'receiverId' : 'senderId', 'userId username profile.displayName profile.avatar')
        .lean(),
      GiftTransaction.countDocuments(query),
    ]);

    res.json({
      success: true,
      data: transactions,
      pagination: { page, limit, total, pages: Math.ceil(total / limit) },
    });
  } catch (error) {
    next(error);
  }
};
