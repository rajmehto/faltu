const nodemailer = require('nodemailer');
const logger = require('../utils/logger');

let transporter;

function getTransporter() {
  if (transporter) return transporter;

  transporter = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.sendgrid.net',
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true',
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });

  return transporter;
}

const emailTemplates = {
  'email-verification': (data) => ({
    subject: 'Verify your Tango Live email',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #E91E8C, #9C27B0); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
          <h1 style="color: white; margin: 0;">🎥 Tango Live</h1>
        </div>
        <div style="padding: 30px; background: #1a1a2e; color: #ffffff;">
          <h2>Hi ${data.displayName}!</h2>
          <p>Welcome to Tango Live. Please verify your email address:</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${data.verificationUrl}" style="background: linear-gradient(135deg, #E91E8C, #9C27B0); color: white; padding: 14px 30px; text-decoration: none; border-radius: 8px; font-weight: bold;">Verify Email</a>
          </div>
          <p style="color: #888;">This link expires in 24 hours.</p>
        </div>
      </div>
    `,
  }),
  'password-reset': (data) => ({
    subject: 'Reset your Tango Live password',
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #E91E8C, #9C27B0); padding: 30px; text-align: center; border-radius: 10px 10px 0 0;">
          <h1 style="color: white; margin: 0;">🎥 Tango Live</h1>
        </div>
        <div style="padding: 30px; background: #1a1a2e; color: #ffffff;">
          <h2>Hi ${data.displayName}!</h2>
          <p>You requested a password reset. Click the button below:</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${data.resetUrl}" style="background: linear-gradient(135deg, #E91E8C, #9C27B0); color: white; padding: 14px 30px; text-decoration: none; border-radius: 8px; font-weight: bold;">Reset Password</a>
          </div>
          <p style="color: #888;">This link expires in ${data.expiresIn}. If you didn't request this, ignore this email.</p>
        </div>
      </div>
    `,
  }),
  'gift-notification': (data) => ({
    subject: `🎁 ${data.senderName} sent you a gift!`,
    html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="padding: 30px; background: #1a1a2e; color: #ffffff;">
          <h2>You received a gift!</h2>
          <p>${data.senderName} sent you ${data.giftName} worth ${data.value} coins on Tango Live!</p>
        </div>
      </div>
    `,
  }),
};

async function sendEmail({ to, subject, template, html, data = {} }) {
  try {
    const transport = getTransporter();
    let emailContent = { subject, html };

    if (template && emailTemplates[template]) {
      emailContent = emailTemplates[template](data);
    }

    const info = await transport.sendMail({
      from: `"Tango Live" <${process.env.SMTP_FROM || 'noreply@tangolive.app'}>`,
      to,
      subject: emailContent.subject,
      html: emailContent.html,
    });

    logger.info(`Email sent to ${to}: ${info.messageId}`);
    return info;
  } catch (error) {
    logger.error(`Email send failed to ${to}:`, error);
    throw error;
  }
}

module.exports = { sendEmail };
