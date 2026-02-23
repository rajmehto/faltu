const express = require('express');
const router = express.Router();
const { body } = require('express-validator');

const authController = require('../controllers/auth.controller');
const { authenticate } = require('../middlewares/auth.middleware');
const { authRateLimit } = require('../middlewares/rateLimit.middleware');
const { validateRequest } = require('../middlewares/validation.middleware');

router.post('/register',
  authRateLimit,
  [
    body('username').trim().isLength({ min: 3, max: 30 }).matches(/^[a-zA-Z0-9_]+$/).withMessage('Username must be 3-30 alphanumeric characters'),
    body('email').optional().isEmail().normalizeEmail(),
    body('password').optional().isLength({ min: 6 }).withMessage('Password must be at least 6 characters'),
    body('displayName').optional().trim().isLength({ max: 50 }),
  ],
  validateRequest,
  authController.register
);

router.post('/login',
  authRateLimit,
  [
    body('emailOrUsername').notEmpty().withMessage('Email or username is required'),
    body('password').notEmpty().withMessage('Password is required'),
  ],
  validateRequest,
  authController.login
);

router.post('/social/login',
  authRateLimit,
  [
    body('provider').isIn(['google', 'facebook', 'apple']).withMessage('Invalid provider'),
    body('token').notEmpty().withMessage('Token is required'),
  ],
  validateRequest,
  authController.socialLogin
);

router.post('/logout', authenticate, authController.logout);

router.post('/refresh',
  [body('refreshToken').notEmpty()],
  validateRequest,
  authController.refreshToken
);

router.post('/forgot-password',
  authRateLimit,
  [body('email').isEmail().normalizeEmail()],
  validateRequest,
  authController.forgotPassword
);

router.post('/reset-password',
  authRateLimit,
  [
    body('token').notEmpty(),
    body('password').isLength({ min: 6 }),
  ],
  validateRequest,
  authController.resetPassword
);

router.post('/phone/send-otp',
  authRateLimit,
  [body('phone').notEmpty().isMobilePhone()],
  validateRequest,
  authController.sendPhoneOtp
);

router.post('/phone/verify-otp',
  authRateLimit,
  [
    body('phone').notEmpty().isMobilePhone(),
    body('otp').isLength({ min: 6, max: 6 }).isNumeric(),
  ],
  validateRequest,
  authController.verifyPhoneOtp
);

router.post('/2fa/enable', authenticate, authController.enable2FA);

router.post('/2fa/verify',
  [body('code').isLength({ min: 6, max: 6 }).isNumeric()],
  validateRequest,
  authController.verify2FA
);

router.post('/fcm-token',
  authenticate,
  [body('fcmToken').notEmpty()],
  validateRequest,
  authController.updateFcmToken
);

module.exports = router;
