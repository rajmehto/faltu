const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { getFromCache, setCache } = require('../config/redis');
const logger = require('../utils/logger');

exports.authenticate = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return res.status(401).json({
        success: false,
        message: 'No authentication token provided',
      });
    }

    const token = authHeader.split(' ')[1];

    let decoded;
    try {
      decoded = jwt.verify(token, process.env.JWT_SECRET);
    } catch (err) {
      if (err.name === 'TokenExpiredError') {
        return res.status(401).json({
          success: false,
          message: 'Token expired',
          code: 'TOKEN_EXPIRED',
        });
      }
      return res.status(401).json({
        success: false,
        message: 'Invalid token',
      });
    }

    const cacheKey = `user:${decoded.userId}`;
    let user = await getFromCache(cacheKey);

    if (!user) {
      user = await User.findOne({
        userId: decoded.userId,
        isActive: true,
        deletedAt: null,
      }).lean();

      if (user) {
        await setCache(cacheKey, user, 300);
      }
    }

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.moderation?.isBanned) {
      const isActiveBan = !user.moderation.banUntil ||
        user.moderation.banUntil > new Date() ||
        user.moderation.isPermanentBan;

      if (isActiveBan) {
        return res.status(403).json({
          success: false,
          message: 'Account suspended',
          banReason: user.moderation.banReason,
          banUntil: user.moderation.banUntil,
        });
      }
    }

    req.user = user;
    next();
  } catch (error) {
    logger.error('Auth middleware error:', error);
    next(error);
  }
};

exports.optionalAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      req.user = null;
      return next();
    }

    const token = authHeader.split(' ')[1];
    try {
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findOne({ userId: decoded.userId, isActive: true }).lean();
      req.user = user || null;
    } catch {
      req.user = null;
    }
    next();
  } catch (error) {
    next(error);
  }
};

exports.requireRole = (...roles) => {
  return async (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Authentication required' });
    }

    const { getPostgresPool } = require('../config/database');
    const pool = getPostgresPool();

    const result = await pool.query(
      'SELECT role, permissions FROM admin_users WHERE user_id = $1 AND is_active = true',
      [req.user.userId]
    );

    if (result.rows.length === 0) {
      return res.status(403).json({ success: false, message: 'Insufficient permissions' });
    }

    const adminUser = result.rows[0];
    if (!roles.includes(adminUser.role)) {
      return res.status(403).json({ success: false, message: 'Insufficient permissions' });
    }

    req.adminRole = adminUser.role;
    req.adminPermissions = adminUser.permissions;
    next();
  };
};

exports.requireVerified = (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ success: false, message: 'Authentication required' });
  }

  if (!req.user.auth?.emailVerified && !req.user.auth?.phoneVerified) {
    return res.status(403).json({
      success: false,
      message: 'Please verify your email or phone number',
    });
  }

  next();
};
