// MongoDB Schema Initialization Script
// This creates the initial collections and indexes for Tango Live

// Users Collection
db.createCollection('users', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['userId', 'username', 'profile'],
      properties: {
        userId: { bsonType: 'string' },
        username: { bsonType: 'string', pattern: '^[a-zA-Z0-9_]{3,30}$' },
        email: { bsonType: 'string' },
        phone: { bsonType: 'string' },
        passwordHash: { bsonType: 'string' },
        profile: {
          bsonType: 'object',
          required: ['displayName'],
          properties: {
            avatar: { bsonType: 'string' },
            coverImage: { bsonType: 'string' },
            displayName: { bsonType: 'string', maxLength: 50 },
            bio: { bsonType: 'string', maxLength: 150 },
            birthday: { bsonType: 'date' },
            gender: { enum: ['male', 'female', 'other', 'prefer_not_to_say'] },
            country: { bsonType: 'string' },
            city: { bsonType: 'string' },
            verified: { bsonType: 'bool' },
            level: { bsonType: 'int', minimum: 1 },
            xp: { bsonType: 'int', minimum: 0 }
          }
        },
        isActive: { bsonType: 'bool' },
        deletedAt: { bsonType: 'date' },
        createdAt: { bsonType: 'date' },
        updatedAt: { bsonType: 'date' }
      }
    }
  }
});

db.users.createIndex({ userId: 1 }, { unique: true });
db.users.createIndex({ username: 1 }, { unique: true, sparse: true });
db.users.createIndex({ email: 1 }, { unique: true, sparse: true });
db.users.createIndex({ phone: 1 }, { unique: true, sparse: true });
db.users.createIndex({ 'profile.displayName': 'text', username: 'text' });
db.users.createIndex({ 'profile.country': 1 });
db.users.createIndex({ 'stats.followers': -1 });
db.users.createIndex({ createdAt: -1 });

// Streams Collection
db.createCollection('streams', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['streamId', 'streamerId', 'title'],
      properties: {
        streamId: { bsonType: 'string' },
        streamerId: { bsonType: 'objectId' },
        title: { bsonType: 'string', maxLength: 100 },
        description: { bsonType: 'string', maxLength: 500 },
        thumbnail: { bsonType: 'string' },
        category: { bsonType: 'string' },
        tags: { bsonType: 'array', items: { bsonType: 'string' } },
        status: { enum: ['scheduled', 'live', 'ended', 'replay'] },
        scheduledAt: { bsonType: 'date' },
        startedAt: { bsonType: 'date' },
        endedAt: { bsonType: 'date' },
        createdAt: { bsonType: 'date' },
        updatedAt: { bsonType: 'date' }
      }
    }
  }
});

db.streams.createIndex({ streamId: 1 }, { unique: true });
db.streams.createIndex({ streamerId: 1 });
db.streams.createIndex({ status: 1 });
db.streams.createIndex({ category: 1 });
db.streams.createIndex({ 'stats.currentViewers': -1 });
db.streams.createIndex({ createdAt: -1 });
db.streams.createIndex({ scheduledAt: 1 });

// Chat Messages Collection
db.createCollection('chatmessages', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['messageId', 'streamId', 'userId', 'content'],
      properties: {
        messageId: { bsonType: 'string' },
        streamId: { bsonType: 'objectId' },
        userId: { bsonType: 'objectId' },
        type: { enum: ['text', 'emoji', 'sticker', 'image', 'gift', 'system', 'super_chat'] },
        content: { bsonType: 'string', maxLength: 1000 },
        metadata: { bsonType: 'object' },
        replyTo: { bsonType: 'objectId' },
        reactions: { bsonType: 'array' },
        isDeleted: { bsonType: 'bool' },
        isPinned: { bsonType: 'bool' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.chatmessages.createIndex({ messageId: 1 }, { unique: true });
db.chatmessages.createIndex({ streamId: 1, createdAt: -1 });
db.chatmessages.createIndex({ userId: 1 });
db.chatmessages.createIndex({ streamId: 1, isPinned: -1 });

// Gifts Collection
db.createCollection('gifts', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['giftId', 'name', 'price'],
      properties: {
        giftId: { bsonType: 'string' },
        name: { bsonType: 'string' },
        description: { bsonType: 'string' },
        category: { enum: ['rose', 'car', 'house', 'premium', 'limited', 'emoji', 'sticker'] },
        image: { bsonType: 'string' },
        animation: { bsonType: 'string' },
        sound: { bsonType: 'string' },
        price: {
          bsonType: 'object',
          properties: {
            coins: { bsonType: 'int' },
            diamonds: { bsonType: 'int' }
          }
        },
        rarity: { enum: ['common', 'rare', 'epic', 'legendary', 'limited'] },
        isLimited: { bsonType: 'bool' },
        limitedQuantity: { bsonType: 'int' },
        isActive: { bsonType: 'bool' },
        createdAt: { bsonType: 'date' },
        updatedAt: { bsonType: 'date' }
      }
    }
  }
});

db.gifts.createIndex({ giftId: 1 }, { unique: true });
db.gifts.createIndex({ category: 1 });
db.gifts.createIndex({ isActive: 1 });
db.gifts.createIndex({ 'price.coins': 1 });

// Gift Transactions Collection
db.createCollection('gifttransactions', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['transactionId', 'fromUserId', 'giftId'],
      properties: {
        transactionId: { bsonType: 'string' },
        fromUserId: { bsonType: 'objectId' },
        toUserId: { bsonType: 'objectId' },
        streamId: { bsonType: 'objectId' },
        giftId: { bsonType: 'objectId' },
        quantity: { bsonType: 'int', minimum: 1 },
        value: { bsonType: 'int' },
        timestamp: { bsonType: 'date' }
      }
    }
  }
});

db.gifttransactions.createIndex({ transactionId: 1 }, { unique: true });
db.gifttransactions.createIndex({ fromUserId: 1, timestamp: -1 });
db.gifttransactions.createIndex({ toUserId: 1, timestamp: -1 });
db.gifttransactions.createIndex({ streamId: 1 });

// Rooms Collection (Voice Rooms, Party Rooms)
db.createCollection('rooms', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['roomId', 'hostId', 'name', 'type'],
      properties: {
        roomId: { bsonType: 'string' },
        hostId: { bsonType: 'objectId' },
        name: { bsonType: 'string' },
        description: { bsonType: 'string' },
        thumbnail: { bsonType: 'string' },
        category: { bsonType: 'string' },
        type: { enum: ['voice_chat', 'party_room', 'game_room'] },
        maxParticipants: { bsonType: 'int', minimum: 2, maximum: 1000 },
        currentParticipants: { bsonType: 'int', default: 0 },
        status: { enum: ['active', 'ended'] },
        createdAt: { bsonType: 'date' },
        endedAt: { bsonType: 'date' }
      }
    }
  }
});

db.rooms.createIndex({ roomId: 1 }, { unique: true });
db.rooms.createIndex({ hostId: 1 });
db.rooms.createIndex({ type: 1, status: 1 });
db.rooms.createIndex({ category: 1 });
db.rooms.createIndex({ createdAt: -1 });

// Events Collection
db.createCollection('events', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['eventId', 'title', 'organizerId'],
      properties: {
        eventId: { bsonType: 'string' },
        title: { bsonType: 'string' },
        description: { bsonType: 'string' },
        thumbnail: { bsonType: 'string' },
        organizerId: { bsonType: 'objectId' },
        streamId: { bsonType: 'objectId' },
        type: { enum: ['tournament', 'contest', 'special', 'featured'] },
        category: { bsonType: 'string' },
        startDate: { bsonType: 'date' },
        endDate: { bsonType: 'date' },
        rsvpCount: { bsonType: 'int', default: 0 },
        maxAttendees: { bsonType: 'int' },
        status: { enum: ['upcoming', 'ongoing', 'ended', 'cancelled'] },
        createdAt: { bsonType: 'date' },
        updatedAt: { bsonType: 'date' }
      }
    }
  }
});

db.events.createIndex({ eventId: 1 }, { unique: true });
db.events.createIndex({ organizerId: 1 });
db.events.createIndex({ type: 1, status: 1 });
db.events.createIndex({ startDate: 1 });
db.events.createIndex({ status: 1, startDate: 1 });

// Music Collection
db.createCollection('music', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['musicId', 'title', 'artist', 'audioUrl'],
      properties: {
        musicId: { bsonType: 'string' },
        title: { bsonType: 'string' },
        artist: { bsonType: 'string' },
        album: { bsonType: 'string' },
        coverImage: { bsonType: 'string' },
        audioUrl: { bsonType: 'string' },
        duration: { bsonType: 'int' },
        category: { bsonType: 'string' },
        isLicensed: { bsonType: 'bool' },
        isPopular: { bsonType: 'bool' },
        isActive: { bsonType: 'bool' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.music.createIndex({ musicId: 1 }, { unique: true });
db.music.createIndex({ title: 'text', artist: 'text' });
db.music.createIndex({ category: 1 });
db.music.createIndex({ isPopular: 1, isActive: 1 });

// Notifications Collection
db.createCollection('notifications', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['notificationId', 'userId', 'type', 'title'],
      properties: {
        notificationId: { bsonType: 'string' },
        userId: { bsonType: 'objectId' },
        type: { enum: ['follow', 'gift', 'mention', 'comment', 'system', 'stream_start', 'achievement'] },
        title: { bsonType: 'string' },
        message: { bsonType: 'string' },
        data: { bsonType: 'object' },
        isRead: { bsonType: 'bool' },
        readAt: { bsonType: 'date' },
        actionUrl: { bsonType: 'string' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.notifications.createIndex({ notificationId: 1 }, { unique: true });
db.notifications.createIndex({ userId: 1, createdAt: -1 });
db.notifications.createIndex({ userId: 1, isRead: 1 });

// Reports Collection
db.createCollection('reports', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['reportId', 'reporterId', 'type', 'reason'],
      properties: {
        reportId: { bsonType: 'string' },
        reporterId: { bsonType: 'objectId' },
        reportedUserId: { bsonType: 'objectId' },
        reportedStreamId: { bsonType: 'objectId' },
        reportedMessageId: { bsonType: 'objectId' },
        type: { enum: ['user', 'stream', 'message', 'comment'] },
        reason: { bsonType: 'string' },
        description: { bsonType: 'string' },
        category: { enum: ['harassment', 'inappropriate_content', 'spam', 'violence', 'fraud', 'other'] },
        status: { enum: ['pending', 'under_review', 'resolved', 'dismissed'] },
        severity: { enum: ['low', 'medium', 'high', 'critical'] },
        resolvedBy: { bsonType: 'objectId' },
        resolvedAt: { bsonType: 'date' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.reports.createIndex({ reportId: 1 }, { unique: true });
db.reports.createIndex({ status: 1 });
db.reports.createIndex({ reporterId: 1 });
db.reports.createIndex({ reportedUserId: 1 });
db.reports.createIndex({ createdAt: -1 });

// Achievements Collection
db.createCollection('achievements', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['achievementId', 'name', 'type', 'criteria'],
      properties: {
        achievementId: { bsonType: 'string' },
        name: { bsonType: 'string' },
        description: { bsonType: 'string' },
        icon: { bsonType: 'string' },
        type: { enum: ['streaming', 'gifting', 'watching', 'social'] },
        criteria: {
          bsonType: 'object',
          properties: {
            type: { bsonType: 'string' },
            value: { bsonType: 'int' }
          }
        },
        rewards: {
          bsonType: 'object',
          properties: {
            xp: { bsonType: 'int' },
            coins: { bsonType: 'int' },
            badge: { bsonType: 'string' }
          }
        },
        level: { bsonType: 'int' },
        isActive: { bsonType: 'bool' }
      }
    }
  }
});

db.achievements.createIndex({ achievementId: 1 }, { unique: true });
db.achievements.createIndex({ type: 1 });
db.achievements.createIndex({ isActive: 1 });

// Follows Collection
db.createCollection('follows', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['followerId', 'followingId'],
      properties: {
        followerId: { bsonType: 'objectId' },
        followingId: { bsonType: 'objectId' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.follows.createIndex({ followerId: 1, followingId: 1 }, { unique: true });
db.follows.createIndex({ followingId: 1 });
db.follows.createIndex({ createdAt: -1 });

// Blocks Collection
db.createCollection('blocks', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['blockerId', 'blockedId'],
      properties: {
        blockerId: { bsonType: 'objectId' },
        blockedId: { bsonType: 'objectId' },
        reason: { bsonType: 'string' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.blocks.createIndex({ blockerId: 1, blockedId: 1 }, { unique: true });
db.blocks.createIndex({ blockedId: 1 });

// Categories Collection
db.createCollection('categories', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['categoryId', 'name', 'slug'],
      properties: {
        categoryId: { bsonType: 'string' },
        name: { bsonType: 'string' },
        slug: { bsonType: 'string' },
        description: { bsonType: 'string' },
        icon: { bsonType: 'string' },
        image: { bsonType: 'string' },
        isActive: { bsonType: 'bool' },
        order: { bsonType: 'int' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.categories.createIndex({ categoryId: 1 }, { unique: true });
db.categories.createIndex({ slug: 1 }, { unique: true });
db.categories.createIndex({ isActive: 1, order: 1 });

// Moderation Actions Collection
db.createCollection('moderationactions', {
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: ['actionId', 'moderatorId', 'targetUserId', 'type'],
      properties: {
        actionId: { bsonType: 'string' },
        moderatorId: { bsonType: 'objectId' },
        targetUserId: { bsonType: 'objectId' },
        targetStreamId: { bsonType: 'objectId' },
        type: { enum: ['warning', 'mute', 'timeout', 'ban', 'delete_content'] },
        reason: { bsonType: 'string' },
        duration: { bsonType: 'int' },
        evidence: { bsonType: 'array' },
        notes: { bsonType: 'string' },
        createdAt: { bsonType: 'date' }
      }
    }
  }
});

db.moderationactions.createIndex({ actionId: 1 }, { unique: true });
db.moderationactions.createIndex({ moderatorId: 1, createdAt: -1 });
db.moderationactions.createIndex({ targetUserId: 1, createdAt: -1 });

print('MongoDB collections and indexes created successfully!');
