const { v4: uuidv4 } = require('uuid');
const jwt = require('jsonwebtoken');
const speakeasy = require('speakeasy');
const qrcode = require('qrcode');

const User = require('../models/User');
const { sendPushNotification } = require('../config/firebase');
const { setCache, deleteCache } = require('../config/redis');
const { sendEmail } = require('../services/email.service');
const { sendSMS } = require('../services/sms.service');
const { generateTokens, generateRefreshToken } = require('../utils/jwt');
const logger = require('../utils/logger');

const generateAccessToken = (userId) => {
  return jwt.sign({ userId }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '15m',
  });
};

exports.register = async (req, res, next) => {
  try {
    const { username, email, password, phone, displayName } = req.body;

    const existingUser = await User.findOne({
      $or: [
        ...(email ? [{ email: email.toLowerCase() }] : []),
        { username: username.toLowerCase() },
        ...(phone ? [{ phone }] : []),
      ],
    });

    if (existingUser) {
      const field = existingUser.email === email?.toLowerCase() ? 'email' :
                    existingUser.username === username.toLowerCase() ? 'username' : 'phone';
      return res.status(400).json({
        success: false,
        message: `This ${field} is already in use`,
      });
    }

    const userId = uuidv4();
    const user = new User({
      userId,
      username: username.toLowerCase(),
      email: email?.toLowerCase(),
      phone,
      profile: {
        displayName: displayName || username,
        level: 1,
        xp: 0,
        verified: false,
      },
      auth: {
        providers: email ? ['email'] : ['phone'],
        emailVerified: false,
        phoneVerified: false,
      },
    });

    if (password) {
      await user.setPassword(password);
    }

    const emailVerificationToken = uuidv4();
    user.auth.emailVerificationToken = emailVerificationToken;

    await user.save();

    if (email) {
      await sendEmail({
        to: email,
        subject: 'Welcome to Tango Live - Verify your email',
        template: 'email-verification',
        data: {
          displayName: user.profile.displayName,
          verificationUrl: `${process.env.APP_URL}/verify-email?token=${emailVerificationToken}`,
        },
      }).catch(err => logger.error('Email send error:', err));
    }

    const { accessToken, refreshToken } = generateTokens(userId);

    await User.updateOne(
      { userId },
      { $push: { 'auth.refreshTokens': refreshToken } }
    );

    const userData = user.toObject();
    delete userData.passwordHash;
    delete userData.auth.refreshTokens;
    delete userData.auth.twoFactorSecret;

    res.status(201).json({
      success: true,
      message: 'Registration successful',
      data: {
        user: userData,
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { emailOrUsername, password } = req.body;

    const user = await User.findByEmailOrUsername(emailOrUsername);

    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    if (user.moderation.isBanned) {
      const isTempBan = user.moderation.banUntil && user.moderation.banUntil > new Date();
      const isPermanentBan = user.moderation.isPermanentBan;

      if (isPermanentBan || isTempBan) {
        return res.status(403).json({
          success: false,
          message: `Account suspended. Reason: ${user.moderation.banReason || 'Policy violation'}`,
          banUntil: user.moderation.banUntil,
          isPermanent: isPermanentBan,
        });
      }
    }

    const isPasswordValid = await user.comparePassword(password);
    if (!isPasswordValid) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials',
      });
    }

    if (user.auth.twoFactorEnabled) {
      const tempToken = jwt.sign(
        { userId: user.userId, requires2FA: true },
        process.env.JWT_SECRET,
        { expiresIn: '10m' }
      );

      return res.status(200).json({
        success: true,
        requires2FA: true,
        tempToken,
      });
    }

    const { accessToken, refreshToken } = generateTokens(user.userId);

    await User.updateOne(
      { userId: user.userId },
      {
        $push: { 'auth.refreshTokens': refreshToken },
        $set: { 'auth.lastLogin': new Date() },
        $inc: { 'auth.loginCount': 1 },
      }
    );

    const userData = user.toObject();
    delete userData.passwordHash;
    delete userData.auth.refreshTokens;
    delete userData.auth.twoFactorSecret;

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        user: userData,
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.socialLogin = async (req, res, next) => {
  try {
    const { provider, token, email, displayName } = req.body;

    let providerUserId, providerEmail, providerName;

    if (provider === 'google') {
      const { verifyFirebaseToken } = require('../config/firebase');
      const decoded = await verifyFirebaseToken(token);
      providerUserId = decoded.uid;
      providerEmail = decoded.email;
      providerName = decoded.name || displayName;
    } else if (provider === 'facebook') {
      const response = await require('axios').get(
        `https://graph.facebook.com/me?access_token=${token}&fields=id,name,email`
      );
      providerUserId = response.data.id;
      providerEmail = response.data.email || email;
      providerName = response.data.name || displayName;
    } else if (provider === 'apple') {
      const { verifyAppleToken } = require('../utils/appleAuth');
      const decoded = await verifyAppleToken(token);
      providerUserId = decoded.sub;
      providerEmail = decoded.email || email;
      providerName = displayName;
    } else {
      return res.status(400).json({ success: false, message: 'Invalid provider' });
    }

    let user = await User.findOne({ email: providerEmail?.toLowerCase() })
      .select('+auth.refreshTokens');

    if (!user) {
      const userId = uuidv4();
      const username = await generateUniqueUsername(providerName || providerEmail?.split('@')[0] || 'user');

      user = new User({
        userId,
        username,
        email: providerEmail?.toLowerCase(),
        profile: {
          displayName: providerName || username,
          verified: false,
          level: 1,
          xp: 0,
        },
        auth: {
          providers: [provider],
          emailVerified: !!providerEmail,
        },
      });
      await user.save();
    } else if (!user.auth.providers.includes(provider)) {
      await User.updateOne(
        { userId: user.userId },
        { $addToSet: { 'auth.providers': provider } }
      );
    }

    const { accessToken, refreshToken } = generateTokens(user.userId);

    await User.updateOne(
      { userId: user.userId },
      {
        $push: { 'auth.refreshTokens': refreshToken },
        $set: { 'auth.lastLogin': new Date() },
        $inc: { 'auth.loginCount': 1 },
      }
    );

    const userData = user.toObject();
    delete userData.passwordHash;
    delete userData.auth.refreshTokens;

    res.json({
      success: true,
      data: {
        user: userData,
        accessToken,
        refreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.logout = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;
    const userId = req.user.userId;

    if (refreshToken) {
      await User.updateOne(
        { userId },
        { $pull: { 'auth.refreshTokens': refreshToken } }
      );
    }

    await deleteCache(`session:${userId}`);

    res.json({ success: true, message: 'Logged out successfully' });
  } catch (error) {
    next(error);
  }
};

exports.refreshToken = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({ success: false, message: 'Refresh token required' });
    }

    let decoded;
    try {
      decoded = jwt.verify(refreshToken, process.env.JWT_REFRESH_SECRET);
    } catch {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    const user = await User.findOne({ userId: decoded.userId })
      .select('+auth.refreshTokens');

    if (!user || !user.auth.refreshTokens.includes(refreshToken)) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }

    const { accessToken, refreshToken: newRefreshToken } = generateTokens(user.userId);

    await User.updateOne(
      { userId: user.userId },
      {
        $pull: { 'auth.refreshTokens': refreshToken },
        $push: { 'auth.refreshTokens': newRefreshToken },
      }
    );

    res.json({
      success: true,
      data: {
        accessToken,
        refreshToken: newRefreshToken,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    const user = await User.findOne({ email: email.toLowerCase() });

    if (!user) {
      return res.json({
        success: true,
        message: 'If this email exists, a reset link has been sent',
      });
    }

    const resetToken = uuidv4();
    const resetExpiry = new Date(Date.now() + 60 * 60 * 1000);

    await User.updateOne(
      { userId: user.userId },
      {
        'auth.passwordResetToken': resetToken,
        'auth.passwordResetExpires': resetExpiry,
      }
    );

    await sendEmail({
      to: email,
      subject: 'Tango Live - Password Reset Request',
      template: 'password-reset',
      data: {
        displayName: user.profile.displayName,
        resetUrl: `${process.env.APP_URL}/reset-password?token=${resetToken}`,
        expiresIn: '1 hour',
      },
    });

    res.json({
      success: true,
      message: 'If this email exists, a reset link has been sent',
    });
  } catch (error) {
    next(error);
  }
};

exports.resetPassword = async (req, res, next) => {
  try {
    const { token, password } = req.body;

    const user = await User.findOne({
      'auth.passwordResetToken': token,
      'auth.passwordResetExpires': { $gt: new Date() },
    });

    if (!user) {
      return res.status(400).json({
        success: false,
        message: 'Invalid or expired reset token',
      });
    }

    await user.setPassword(password);
    user.auth.passwordResetToken = undefined;
    user.auth.passwordResetExpires = undefined;
    user.auth.refreshTokens = [];
    user.auth.passwordChangedAt = new Date();

    await user.save();

    res.json({ success: true, message: 'Password reset successfully' });
  } catch (error) {
    next(error);
  }
};

exports.sendPhoneOtp = async (req, res, next) => {
  try {
    const { phone } = req.body;

    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const ttl = 300;

    await setCache(`otp:${phone}`, { otp, attempts: 0 }, ttl);

    await sendSMS({
      to: phone,
      body: `Your Tango Live verification code is: ${otp}. Valid for 5 minutes.`,
    });

    res.json({ success: true, message: 'OTP sent successfully' });
  } catch (error) {
    next(error);
  }
};

exports.verifyPhoneOtp = async (req, res, next) => {
  try {
    const { phone, otp } = req.body;
    const { getFromCache } = require('../config/redis');

    const stored = await getFromCache(`otp:${phone}`);
    if (!stored) {
      return res.status(400).json({ success: false, message: 'OTP expired' });
    }

    if (stored.attempts >= 3) {
      await deleteCache(`otp:${phone}`);
      return res.status(400).json({ success: false, message: 'Too many attempts. Request a new OTP.' });
    }

    if (stored.otp !== otp) {
      stored.attempts += 1;
      await setCache(`otp:${phone}`, stored, 300);
      return res.status(400).json({ success: false, message: 'Invalid OTP' });
    }

    await deleteCache(`otp:${phone}`);

    let user = await User.findOne({ phone });
    if (!user) {
      const userId = uuidv4();
      const username = await generateUniqueUsername(`user${Date.now().toString(36)}`);

      user = new User({
        userId,
        username,
        phone,
        profile: {
          displayName: username,
          verified: false,
          level: 1,
          xp: 0,
        },
        auth: {
          providers: ['phone'],
          phoneVerified: true,
        },
      });
      await user.save();
    } else {
      await User.updateOne({ phone }, { 'auth.phoneVerified': true });
    }

    const { accessToken, refreshToken } = generateTokens(user.userId);

    await User.updateOne(
      { userId: user.userId },
      {
        $push: { 'auth.refreshTokens': refreshToken },
        $set: { 'auth.lastLogin': new Date() },
      }
    );

    const userData = user.toObject();
    delete userData.passwordHash;

    res.json({
      success: true,
      data: { user: userData, accessToken, refreshToken },
    });
  } catch (error) {
    next(error);
  }
};

exports.enable2FA = async (req, res, next) => {
  try {
    const userId = req.user.userId;
    const user = await User.findOne({ userId });

    const secret = speakeasy.generateSecret({
      name: `Tango Live (${user.email || user.phone || user.username})`,
      length: 20,
    });

    await User.updateOne({ userId }, { 'auth.twoFactorSecret': secret.base32 });

    const qrCodeDataUrl = await qrcode.toDataURL(secret.otpauth_url);

    res.json({
      success: true,
      data: {
        secret: secret.base32,
        qrCode: qrCodeDataUrl,
        manualKey: secret.base32,
      },
    });
  } catch (error) {
    next(error);
  }
};

exports.verify2FA = async (req, res, next) => {
  try {
    const { code, tempToken } = req.body;

    let userId;
    if (tempToken) {
      const decoded = jwt.verify(tempToken, process.env.JWT_SECRET);
      if (!decoded.requires2FA) {
        return res.status(400).json({ success: false, message: 'Invalid token' });
      }
      userId = decoded.userId;
    } else {
      userId = req.user.userId;
    }

    const user = await User.findOne({ userId }).select('+auth.twoFactorSecret');

    const isValid = speakeasy.totp.verify({
      secret: user.auth.twoFactorSecret,
      encoding: 'base32',
      token: code,
      window: 2,
    });

    if (!isValid) {
      return res.status(400).json({ success: false, message: 'Invalid 2FA code' });
    }

    if (!user.auth.twoFactorEnabled) {
      await User.updateOne({ userId }, { 'auth.twoFactorEnabled': true });
      return res.json({ success: true, message: '2FA enabled successfully' });
    }

    const { accessToken, refreshToken } = generateTokens(userId);
    await User.updateOne(
      { userId },
      {
        $push: { 'auth.refreshTokens': refreshToken },
        $set: { 'auth.lastLogin': new Date() },
      }
    );

    const userData = user.toObject();
    delete userData.auth.twoFactorSecret;

    res.json({
      success: true,
      data: { user: userData, accessToken, refreshToken },
    });
  } catch (error) {
    next(error);
  }
};

exports.updateFcmToken = async (req, res, next) => {
  try {
    const { fcmToken } = req.body;
    await User.updateOne(
      { userId: req.user.userId },
      { 'auth.fcmToken': fcmToken }
    );
    res.json({ success: true });
  } catch (error) {
    next(error);
  }
};

async function generateUniqueUsername(base) {
  const cleaned = base.toLowerCase().replace(/[^a-z0-9_]/g, '').substring(0, 20);
  const candidate = cleaned || 'user';

  const existing = await User.findOne({ username: candidate });
  if (!existing) return candidate;

  let attempt = 1;
  while (attempt <= 100) {
    const variant = `${candidate}${attempt}`;
    const exists = await User.findOne({ username: variant });
    if (!exists) return variant;
    attempt++;
  }

  return `${candidate}${Date.now().toString(36)}`;
}
