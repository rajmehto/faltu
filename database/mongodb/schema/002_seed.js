// Seed Data for Tango Live
// Run this script to populate initial data

// Categories Seed
db.categories.insertMany([
  {
    categoryId: 'cat_001',
    name: 'Music',
    slug: 'music',
    description: 'Live music performances, singing, and musical talents',
    icon: 'music_note',
    image: 'https://example.com/categories/music.jpg',
    isActive: true,
    order: 1,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_002',
    name: 'Gaming',
    slug: 'gaming',
    description: 'Video game streaming and gameplay',
    icon: 'sports_esports',
    image: 'https://example.com/categories/gaming.jpg',
    isActive: true,
    order: 2,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_003',
    name: 'Dance',
    slug: 'dance',
    description: 'Dance performances and choreography',
    icon: 'directions_walk',
    image: 'https://example.com/categories/dance.jpg',
    isActive: true,
    order: 3,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_004',
    name: 'Talk Shows',
    slug: 'talk-shows',
    description: 'Live discussions, interviews, and conversations',
    icon: 'forum',
    image: 'https://example.com/categories/talk.jpg',
    isActive: true,
    order: 4,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_005',
    name: 'Food & Cooking',
    slug: 'food',
    description: 'Cooking shows and food preparation',
    icon: 'restaurant',
    image: 'https://example.com/categories/food.jpg',
    isActive: true,
    order: 5,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_006',
    name: 'Sports',
    slug: 'sports',
    description: 'Sports commentary and athletic content',
    icon: 'sports_soccer',
    image: 'https://example.com/categories/sports.jpg',
    isActive: true,
    order: 6,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_007',
    name: 'Fashion',
    slug: 'fashion',
    description: 'Fashion shows, styling tips, and beauty',
    icon: 'checkroom',
    image: 'https://example.com/categories/fashion.jpg',
    isActive: true,
    order: 7,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_008',
    name: 'Education',
    slug: 'education',
    description: 'Learning, tutoring, and educational content',
    icon: 'school',
    image: 'https://example.com/categories/education.jpg',
    isActive: true,
    order: 8,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_009',
    name: 'Just Chatting',
    slug: 'just-chatting',
    description: 'Casual conversations and hangouts',
    icon: 'chat',
    image: 'https://example.com/categories/chat.jpg',
    isActive: true,
    order: 9,
    createdAt: new Date()
  },
  {
    categoryId: 'cat_010',
    name: 'Art & Creativity',
    slug: 'art',
    description: 'Art creation, crafts, and creative content',
    icon: 'palette',
    image: 'https://example.com/categories/art.jpg',
    isActive: true,
    order: 10,
    createdAt: new Date()
  }
]);

// Gifts Seed
db.gifts.insertMany([
  // Roses (Common)
  {
    giftId: 'gift_001',
    name: 'Rose',
    description: 'A beautiful rose',
    category: 'rose',
    image: 'https://example.com/gifts/rose.png',
    animation: 'https://example.com/gifts/rose.json',
    price: { coins: 1, diamonds: 0 },
    rarity: 'common',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_002',
    name: 'Bouquet',
    description: 'A lovely bouquet of flowers',
    category: 'rose',
    image: 'https://example.com/gifts/bouquet.png',
    animation: 'https://example.com/gifts/bouquet.json',
    price: { coins: 9, diamonds: 0 },
    rarity: 'common',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_003',
    name: 'Heart',
    description: 'Send your love',
    category: 'emoji',
    image: 'https://example.com/gifts/heart.png',
    animation: 'https://example.com/gifts/heart.json',
    price: { coins: 5, diamonds: 0 },
    rarity: 'common',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  // Premium
  {
    giftId: 'gift_004',
    name: 'Diamond Ring',
    description: 'A sparkling diamond ring',
    category: 'premium',
    image: 'https://example.com/gifts/diamond_ring.png',
    animation: 'https://example.com/gifts/diamond_ring.json',
    price: { coins: 99, diamonds: 10 },
    rarity: 'rare',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_005',
    name: 'Luxury Watch',
    description: 'An elegant timepiece',
    category: 'premium',
    image: 'https://example.com/gifts/watch.png',
    animation: 'https://example.com/gifts/watch.json',
    price: { coins: 299, diamonds: 30 },
    rarity: 'rare',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_006',
    name: 'Perfume',
    description: 'A luxurious fragrance',
    category: 'premium',
    image: 'https://example.com/gifts/perfume.png',
    animation: 'https://example.com/gifts/perfume.json',
    price: { coins: 199, diamonds: 20 },
    rarity: 'rare',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  // Cars
  {
    giftId: 'gift_007',
    name: 'Sports Car',
    description: 'A fancy sports car',
    category: 'car',
    image: 'https://example.com/gifts/sports_car.png',
    animation: 'https://example.com/gifts/sports_car.json',
    price: { coins: 999, diamonds: 100 },
    rarity: 'epic',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_008',
    name: 'Supercar',
    description: 'The ultimate luxury car',
    category: 'car',
    image: 'https://example.com/gifts/supercar.png',
    animation: 'https://example.com/gifts/supercar.json',
    price: { coins: 2999, diamonds: 300 },
    rarity: 'legendary',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  // Houses
  {
    giftId: 'gift_009',
    name: 'Villa',
    description: 'A beautiful villa',
    category: 'house',
    image: 'https://example.com/gifts/villa.png',
    animation: 'https://example.com/gifts/villa.json',
    price: { coins: 4999, diamonds: 500 },
    rarity: 'legendary',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_010',
    name: 'Castle',
    description: 'A majestic castle',
    category: 'house',
    image: 'https://example.com/gifts/castle.png',
    animation: 'https://example.com/gifts/castle.json',
    price: { coins: 9999, diamonds: 1000 },
    rarity: 'legendary',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  // Limited
  {
    giftId: 'gift_011',
    name: 'Golden Dragon',
    description: 'A mythical golden dragon',
    category: 'limited',
    image: 'https://example.com/gifts/dragon.png',
    animation: 'https://example.com/gifts/dragon.json',
    price: { coins: 19999, diamonds: 2000 },
    rarity: 'limited',
    isLimited: true,
    limitedQuantity: 100,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_012',
    name: 'Phoenix',
    description: 'The legendary fire bird',
    category: 'limited',
    image: 'https://example.com/gifts/phoenix.png',
    animation: 'https://example.com/gifts/phoenix.json',
    price: { coins: 29999, diamonds: 3000 },
    rarity: 'limited',
    isLimited: true,
    limitedQuantity: 50,
    isActive: true,
    createdAt: new Date()
  },
  // Stickers
  {
    giftId: 'gift_013',
    name: 'Cute Cat',
    description: 'An adorable cat sticker',
    category: 'sticker',
    image: 'https://example.com/gifts/cat_sticker.png',
    animation: 'https://example.com/gifts/cat_sticker.json',
    price: { coins: 10, diamonds: 0 },
    rarity: 'common',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_014',
    name: 'Funny Dog',
    description: 'A hilarious dog sticker',
    category: 'sticker',
    image: 'https://example.com/gifts/dog_sticker.png',
    animation: 'https://example.com/gifts/dog_sticker.json',
    price: { coins: 10, diamonds: 0 },
    rarity: 'common',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    giftId: 'gift_015',
    name: 'Cool Wave',
    description: 'A cool wave sticker',
    category: 'sticker',
    image: 'https://example.com/gifts/wave_sticker.png',
    animation: 'https://example.com/gifts/wave_sticker.json',
    price: { coins: 15, diamonds: 0 },
    rarity: 'common',
    isLimited: false,
    isActive: true,
    createdAt: new Date()
  }
]);

// Achievements Seed
db.achievements.insertMany([
  // Streaming Achievements
  {
    achievementId: 'ach_001',
    name: 'First Stream',
    description: 'Start your first live stream',
    icon: 'https://example.com/achievements/first_stream.png',
    type: 'streaming',
    criteria: { type: 'streams_count', value: 1 },
    rewards: { xp: 100, coins: 50 },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_002',
    name: 'Streamer Pro',
    description: 'Complete 100 live streams',
    icon: 'https://example.com/achievements/streamer_pro.png',
    type: 'streaming',
    criteria: { type: 'streams_count', value: 100 },
    rewards: { xp: 5000, coins: 1000, badge: 'pro_streamer' },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_003',
    name: 'Marathon Streamer',
    description: 'Stream for 10 hours straight',
    icon: 'https://example.com/achievements/marathon.png',
    type: 'streaming',
    criteria: { type: 'longest_stream_hours', value: 10 },
    rewards: { xp: 3000, coins: 500 },
    level: 1,
    isActive: true
  },
  // Gifting Achievements
  {
    achievementId: 'ach_004',
    name: 'Generous Heart',
    description: 'Send your first gift',
    icon: 'https://example.com/achievements/first_gift.png',
    type: 'gifting',
    criteria: { type: 'gifts_sent_count', value: 1 },
    rewards: { xp: 50, coins: 20 },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_005',
    name: 'Big Spender',
    description: 'Send gifts worth 10,000 coins',
    icon: 'https://example.com/achievements/big_spender.png',
    type: 'gifting',
    criteria: { type: 'total_coins_spent', value: 10000 },
    rewards: { xp: 2000, coins: 500, badge: 'big_spender' },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_006',
    name: 'Gift Master',
    description: 'Send gifts worth 100,000 coins',
    icon: 'https://example.com/achievements/gift_master.png',
    type: 'gifting',
    criteria: { type: 'total_coins_spent', value: 100000 },
    rewards: { xp: 10000, coins: 5000, badge: 'gift_master' },
    level: 1,
    isActive: true
  },
  // Watching Achievements
  {
    achievementId: 'ach_007',
    name: 'Viewer',
    description: 'Watch your first stream',
    icon: 'https://example.com/achievements/first_viewer.png',
    type: 'watching',
    criteria: { type: 'streams_watched', value: 1 },
    rewards: { xp: 20, coins: 10 },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_008',
    name: 'Regular Viewer',
    description: 'Watch 100 streams',
    icon: 'https://example.com/achievements/regular_viewer.png',
    type: 'watching',
    criteria: { type: 'streams_watched', value: 100 },
    rewards: { xp: 1000, coins: 200 },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_009',
    name: 'Stream Fanatic',
    description: 'Watch 500 streams',
    icon: 'https://example.com/achievements/fanatic.png',
    type: 'watching',
    criteria: { type: 'streams_watched', value: 500 },
    rewards: { xp: 5000, coins: 1000, badge: 'stream_fanatic' },
    level: 1,
    isActive: true
  },
  // Social Achievements
  {
    achievementId: 'ach_010',
    name: 'Making Friends',
    description: 'Follow your first streamer',
    icon: 'https://example.com/achievements/first_follow.png',
    type: 'social',
    criteria: { type: 'following_count', value: 1 },
    rewards: { xp: 30, coins: 10 },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_011',
    name: 'Popular',
    description: 'Get 1000 followers',
    icon: 'https://example.com/achievements/popular.png',
    type: 'social',
    criteria: { type: 'followers_count', value: 1000 },
    rewards: { xp: 5000, coins: 1000, badge: 'popular' },
    level: 1,
    isActive: true
  },
  {
    achievementId: 'ach_012',
    name: 'Star',
    description: 'Get 10,000 followers',
    icon: 'https://example.com/achievements/star.png',
    type: 'social',
    criteria: { type: 'followers_count', value: 10000 },
    rewards: { xp: 20000, coins: 5000, badge: 'star' },
    level: 1,
    isActive: true
  }
]);

// Music Seed
db.music.insertMany([
  {
    musicId: 'music_001',
    title: 'Summer Vibes',
    artist: 'DJ Melody',
    album: 'Summer Hits 2024',
    coverImage: 'https://example.com/music/summer.jpg',
    audioUrl: 'https://example.com/music/summer.mp3',
    duration: 180,
    category: 'Electronic',
    isLicensed: true,
    isPopular: true,
    isActive: true,
    createdAt: new Date()
  },
  {
    musicId: 'music_002',
    title: 'Chill Lofi',
    artist: 'LoFi Beats',
    album: 'Relaxation',
    coverImage: 'https://example.com/music/lofi.jpg',
    audioUrl: 'https://example.com/music/lofi.mp3',
    duration: 210,
    category: 'Lo-Fi',
    isLicensed: true,
    isPopular: true,
    isActive: true,
    createdAt: new Date()
  },
  {
    musicId: 'music_003',
    title: 'Dance Floor',
    artist: 'Party Masters',
    album: 'Club Hits',
    coverImage: 'https://example.com/music/dance.jpg',
    audioUrl: 'https://example.com/music/dance.mp3',
    duration: 195,
    category: 'Dance',
    isLicensed: true,
    isPopular: true,
    isActive: true,
    createdAt: new Date()
  },
  {
    musicId: 'music_004',
    title: 'Acoustic Morning',
    artist: 'Guitar Dreams',
    album: 'Unplugged',
    coverImage: 'https://example.com/music/acoustic.jpg',
    audioUrl: 'https://example.com/music/acoustic.mp3',
    duration: 240,
    category: 'Acoustic',
    isLicensed: true,
    isPopular: false,
    isActive: true,
    createdAt: new Date()
  },
  {
    musicId: 'music_005',
    title: 'Hip Hop Beats',
    artist: 'Urban Sounds',
    album: 'Street Life',
    coverImage: 'https://example.com/music/hiphop.jpg',
    audioUrl: 'https://example.com/music/hiphop.mp3',
    duration: 185,
    category: 'Hip Hop',
    isLicensed: true,
    isPopular: true,
    isActive: true,
    createdAt: new Date()
  }
]);

print('Seed data inserted successfully!');
