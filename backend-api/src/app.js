require('dotenv').config();

const express = require('express');
const http = require('http');
const cors = require('cors');
const helmet = require('helmet');
const compression = require('compression');
const morgan = require('morgan');
const { Server } = require('socket.io');

const { connectMongoDB } = require('./config/database');
const { connectRedis } = require('./config/redis');
const { initFirebaseAdmin } = require('./config/firebase');
const { setupSocketHandlers } = require('./websocket');
const { errorHandler } = require('./middlewares/errorHandler.middleware');
const { requestLogger } = require('./middlewares/requestLogger.middleware');
const logger = require('./utils/logger');

const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const streamRoutes = require('./routes/stream.routes');
const chatRoutes = require('./routes/chat.routes');
const giftRoutes = require('./routes/gift.routes');
const walletRoutes = require('./routes/wallet.routes');
const paymentRoutes = require('./routes/payment.routes');
const notificationRoutes = require('./routes/notification.routes');
const analyticsRoutes = require('./routes/analytics.routes');
const discoverRoutes = require('./routes/discover.routes');
const roomRoutes = require('./routes/room.routes');
const eventRoutes = require('./routes/event.routes');
const musicRoutes = require('./routes/music.routes');
const achievementRoutes = require('./routes/achievement.routes');
const adminRoutes = require('./routes/admin.routes');
const systemRoutes = require('./routes/system.routes');

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    methods: ['GET', 'POST'],
    credentials: true,
  },
  transports: ['websocket', 'polling'],
  pingTimeout: 30000,
  pingInterval: 25000,
});

app.set('trust proxy', 1);

app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
  contentSecurityPolicy: false,
}));

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Request-ID'],
}));

app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan('combined', { stream: { write: msg => logger.http(msg.trim()) } }));
app.use(requestLogger);

app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
  });
});

const apiRouter = express.Router();

apiRouter.use('/auth', authRoutes);
apiRouter.use('/users', userRoutes);
apiRouter.use('/streams', streamRoutes);
apiRouter.use('/chat', chatRoutes);
apiRouter.use('/gifts', giftRoutes);
apiRouter.use('/wallet', walletRoutes);
apiRouter.use('/payments', paymentRoutes);
apiRouter.use('/notifications', notificationRoutes);
apiRouter.use('/analytics', analyticsRoutes);
apiRouter.use('/discover', discoverRoutes);
apiRouter.use('/rooms', roomRoutes);
apiRouter.use('/events', eventRoutes);
apiRouter.use('/music', musicRoutes);
apiRouter.use('/achievements', achievementRoutes);
apiRouter.use('/admin', adminRoutes);
apiRouter.use('/system', systemRoutes);

app.use('/api/v1', apiRouter);

app.use('*', (req, res) => {
  res.status(404).json({ success: false, message: 'Route not found' });
});

app.use(errorHandler);

setupSocketHandlers(io);

async function startServer() {
  try {
    await connectMongoDB();
    await connectRedis();
    initFirebaseAdmin();

    const PORT = process.env.PORT || 3000;
    server.listen(PORT, () => {
      logger.info(`🚀 Tango Live API running on port ${PORT}`);
      logger.info(`📊 Environment: ${process.env.NODE_ENV}`);
      logger.info(`🔌 WebSocket ready`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
}

process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  server.close(() => {
    logger.info('Server closed');
    process.exit(0);
  });
});

process.on('unhandledRejection', (reason) => {
  logger.error('Unhandled Rejection:', reason);
});

process.on('uncaughtException', (error) => {
  logger.error('Uncaught Exception:', error);
  process.exit(1);
});

startServer();

module.exports = { app, server, io };
