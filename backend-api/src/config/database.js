const mongoose = require('mongoose');
const { Pool } = require('pg');
const logger = require('../utils/logger');

let pgPool = null;

async function connectMongoDB() {
  const uri = process.env.MONGODB_URI || 'mongodb://localhost:27017/tango_live';

  mongoose.connection.on('connected', () => {
    logger.info('✅ MongoDB connected');
  });

  mongoose.connection.on('error', (err) => {
    logger.error('MongoDB connection error:', err);
  });

  mongoose.connection.on('disconnected', () => {
    logger.warn('MongoDB disconnected. Attempting to reconnect...');
  });

  await mongoose.connect(uri, {
    maxPoolSize: 10,
    serverSelectionTimeoutMS: 5000,
    socketTimeoutMS: 45000,
  });
}

async function connectPostgres() {
  pgPool = new Pool({
    host: process.env.PG_HOST || 'localhost',
    port: parseInt(process.env.PG_PORT || '5432'),
    database: process.env.PG_DATABASE || 'tango_live',
    user: process.env.PG_USER || 'postgres',
    password: process.env.PG_PASSWORD || '',
    max: 20,
    idleTimeoutMillis: 30000,
    connectionTimeoutMillis: 2000,
  });

  pgPool.on('error', (err) => {
    logger.error('PostgreSQL pool error:', err);
  });

  const client = await pgPool.connect();
  client.release();
  logger.info('✅ PostgreSQL connected');

  return pgPool;
}

function getPostgresPool() {
  if (!pgPool) {
    throw new Error('PostgreSQL pool not initialized');
  }
  return pgPool;
}

async function closeConnections() {
  await mongoose.connection.close();
  if (pgPool) await pgPool.end();
}

module.exports = {
  connectMongoDB,
  connectPostgres,
  getPostgresPool,
  closeConnections,
};
