const { createClient } = require('redis');
const logger = require('../utils/logger');

let redisClient = null;

async function connectRedis() {
  const url = process.env.REDIS_URL || 'redis://localhost:6379';

  redisClient = createClient({
    url,
    socket: {
      reconnectStrategy: (retries) => {
        if (retries > 20) return new Error('Redis connection failed after 20 retries');
        return Math.min(retries * 100, 3000);
      },
    },
  });

  redisClient.on('connect', () => logger.info('✅ Redis connected'));
  redisClient.on('error', (err) => logger.error('Redis error:', err));
  redisClient.on('reconnecting', () => logger.warn('Redis reconnecting...'));

  await redisClient.connect();
  return redisClient;
}

function getRedisClient() {
  if (!redisClient) {
    throw new Error('Redis client not initialized');
  }
  return redisClient;
}

async function getFromCache(key) {
  try {
    const value = await redisClient.get(key);
    return value ? JSON.parse(value) : null;
  } catch (err) {
    logger.error('Redis get error:', err);
    return null;
  }
}

async function setCache(key, value, ttlSeconds = 300) {
  try {
    await redisClient.setEx(key, ttlSeconds, JSON.stringify(value));
  } catch (err) {
    logger.error('Redis set error:', err);
  }
}

async function deleteCache(key) {
  try {
    await redisClient.del(key);
  } catch (err) {
    logger.error('Redis delete error:', err);
  }
}

async function deleteCachePattern(pattern) {
  try {
    const keys = await redisClient.keys(pattern);
    if (keys.length > 0) {
      await redisClient.del(keys);
    }
  } catch (err) {
    logger.error('Redis delete pattern error:', err);
  }
}

async function incrementCounter(key, ttlSeconds = 86400) {
  try {
    const count = await redisClient.incr(key);
    if (count === 1) {
      await redisClient.expire(key, ttlSeconds);
    }
    return count;
  } catch (err) {
    logger.error('Redis increment error:', err);
    return 0;
  }
}

async function addToSortedSet(key, score, member) {
  try {
    await redisClient.zAdd(key, { score, value: member });
  } catch (err) {
    logger.error('Redis sorted set error:', err);
  }
}

async function getTopFromSortedSet(key, limit = 10) {
  try {
    return await redisClient.zRangeWithScores(key, 0, limit - 1, { REV: true });
  } catch (err) {
    logger.error('Redis sorted set get error:', err);
    return [];
  }
}

async function publishMessage(channel, message) {
  try {
    await redisClient.publish(channel, JSON.stringify(message));
  } catch (err) {
    logger.error('Redis publish error:', err);
  }
}

module.exports = {
  connectRedis,
  getRedisClient,
  getFromCache,
  setCache,
  deleteCache,
  deleteCachePattern,
  incrementCounter,
  addToSortedSet,
  getTopFromSortedSet,
  publishMessage,
};
