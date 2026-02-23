const twilio = require('twilio');
const logger = require('../utils/logger');

let twilioClient;

function getTwilioClient() {
  if (twilioClient) return twilioClient;

  const accountSid = process.env.TWILIO_ACCOUNT_SID;
  const authToken = process.env.TWILIO_AUTH_TOKEN;

  if (!accountSid || !authToken) {
    logger.warn('Twilio credentials not configured');
    return null;
  }

  twilioClient = twilio(accountSid, authToken);
  return twilioClient;
}

async function sendSMS({ to, body }) {
  try {
    const client = getTwilioClient();
    if (!client) {
      logger.info(`[SMS Mock] To: ${to}, Body: ${body}`);
      return { sid: 'mock_sid' };
    }

    const message = await client.messages.create({
      body,
      from: process.env.TWILIO_PHONE_NUMBER,
      to,
    });

    logger.info(`SMS sent to ${to}: ${message.sid}`);
    return message;
  } catch (error) {
    logger.error(`SMS send failed to ${to}:`, error);
    throw error;
  }
}

module.exports = { sendSMS };
