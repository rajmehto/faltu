const admin = require('firebase-admin');
const logger = require('../utils/logger');

function initFirebaseAdmin() {
  if (admin.apps.length > 0) return;

  const serviceAccount = process.env.FIREBASE_SERVICE_ACCOUNT_JSON
    ? JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)
    : null;

  if (serviceAccount) {
    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });
  } else {
    admin.initializeApp({
      credential: admin.credential.applicationDefault(),
      storageBucket: process.env.FIREBASE_STORAGE_BUCKET,
    });
  }

  logger.info('✅ Firebase Admin initialized');
}

async function sendPushNotification({ token, title, body, data = {} }) {
  try {
    const message = {
      token,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
      android: {
        priority: 'high',
        notification: {
          sound: 'default',
          clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      },
      apns: {
        payload: {
          aps: {
            badge: 1,
            sound: 'default',
          },
        },
      },
    };

    const response = await admin.messaging().send(message);
    return response;
  } catch (err) {
    logger.error('FCM send error:', err);
    throw err;
  }
}

async function sendMulticastNotification({ tokens, title, body, data = {} }) {
  if (!tokens || tokens.length === 0) return;

  const batchSize = 500;
  const results = [];

  for (let i = 0; i < tokens.length; i += batchSize) {
    const batch = tokens.slice(i, i + batchSize);
    try {
      const message = {
        tokens: batch,
        notification: { title, body },
        data: Object.fromEntries(
          Object.entries(data).map(([k, v]) => [k, String(v)])
        ),
      };
      const result = await admin.messaging().sendEachForMulticast(message);
      results.push(result);
    } catch (err) {
      logger.error('FCM multicast error:', err);
    }
  }

  return results;
}

async function sendTopicNotification({ topic, title, body, data = {} }) {
  try {
    const message = {
      topic,
      notification: { title, body },
      data: Object.fromEntries(
        Object.entries(data).map(([k, v]) => [k, String(v)])
      ),
    };
    return admin.messaging().send(message);
  } catch (err) {
    logger.error('FCM topic notification error:', err);
  }
}

async function verifyFirebaseToken(token) {
  return admin.auth().verifyIdToken(token);
}

module.exports = {
  initFirebaseAdmin,
  sendPushNotification,
  sendMulticastNotification,
  sendTopicNotification,
  verifyFirebaseToken,
  admin,
};
