const rateLimit = require('express-rate-limit');

exports.globalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 300,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later' },
  skip: (req) => req.path === '/health',
});

exports.authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many login attempts, please try again in 15 minutes' },
});

exports.uploadRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 30,
  message: { success: false, message: 'Upload limit reached' },
});

exports.giftRateLimit = rateLimit({
  windowMs: 60 * 1000,
  max: 30,
  message: { success: false, message: 'Too many gifts in a short period' },
});

exports.chatRateLimit = rateLimit({
  windowMs: 10 * 1000,
  max: 10,
  message: { success: false, message: 'You are sending messages too fast' },
});

exports.streamRateLimit = rateLimit({
  windowMs: 60 * 60 * 1000,
  max: 5,
  message: { success: false, message: 'Stream start limit reached' },
});
