-- Tango Live PostgreSQL Schema
-- Initial Migration

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- Users
CREATE TABLE IF NOT EXISTS users (
    user_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    mongo_id VARCHAR(24) UNIQUE,
    email VARCHAR(255) UNIQUE,
    phone VARCHAR(20) UNIQUE,
    username VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Wallets
CREATE TABLE IF NOT EXISTS wallets (
    wallet_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(36) REFERENCES users(user_id) ON DELETE CASCADE,
    coins_balance DECIMAL(15, 2) DEFAULT 0 CHECK (coins_balance >= 0),
    diamonds_balance DECIMAL(15, 2) DEFAULT 0 CHECK (diamonds_balance >= 0),
    earnings_balance DECIMAL(15, 2) DEFAULT 0 CHECK (earnings_balance >= 0),
    frozen_balance DECIMAL(15, 2) DEFAULT 0 CHECK (frozen_balance >= 0),
    currency VARCHAR(3) DEFAULT 'USD',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id)
);

-- Transactions
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(36) REFERENCES users(user_id) ON DELETE CASCADE,
    wallet_id VARCHAR(36) REFERENCES wallets(wallet_id),
    type VARCHAR(50) NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    payment_method VARCHAR(50),
    payment_intent_id VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    description TEXT,
    metadata JSONB DEFAULT '{}',
    reference_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- Withdrawal Requests
CREATE TABLE IF NOT EXISTS withdrawal_requests (
    withdrawal_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(36) REFERENCES users(user_id),
    amount DECIMAL(15, 2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    method VARCHAR(50) NOT NULL,
    method_details JSONB NOT NULL DEFAULT '{}',
    status VARCHAR(50) DEFAULT 'pending',
    processed_by VARCHAR(36),
    processed_at TIMESTAMP,
    rejection_reason TEXT,
    transaction_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subscription Plans
CREATE TABLE IF NOT EXISTS subscription_plans (
    plan_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    type VARCHAR(50) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    features JSONB NOT NULL DEFAULT '{}',
    stripe_price_id VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User Subscriptions
CREATE TABLE IF NOT EXISTS user_subscriptions (
    subscription_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(36) REFERENCES users(user_id) ON DELETE CASCADE,
    plan_id VARCHAR(36) REFERENCES subscription_plans(plan_id),
    status VARCHAR(50) NOT NULL DEFAULT 'active',
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP,
    auto_renew BOOLEAN DEFAULT true,
    payment_method VARCHAR(50),
    stripe_subscription_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Analytics Events
CREATE TABLE IF NOT EXISTS analytics_events (
    event_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(36),
    stream_id VARCHAR(36),
    session_id VARCHAR(100),
    event_type VARCHAR(100) NOT NULL,
    event_properties JSONB DEFAULT '{}',
    device_info JSONB DEFAULT '{}',
    ip_address INET,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) PARTITION BY RANGE (created_at);

-- Stream Analytics
CREATE TABLE IF NOT EXISTS stream_analytics (
    analytics_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    stream_id VARCHAR(36) NOT NULL,
    streamer_id VARCHAR(36) NOT NULL,
    date DATE NOT NULL,
    total_viewers INTEGER DEFAULT 0,
    unique_viewers INTEGER DEFAULT 0,
    avg_watch_time INTEGER DEFAULT 0,
    peak_concurrent_viewers INTEGER DEFAULT 0,
    new_followers INTEGER DEFAULT 0,
    total_gifts INTEGER DEFAULT 0,
    total_gift_value DECIMAL(15, 2) DEFAULT 0,
    shares INTEGER DEFAULT 0,
    likes INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stream_id, date)
);

-- Admin Users
CREATE TABLE IF NOT EXISTS admin_users (
    admin_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id VARCHAR(36) REFERENCES users(user_id),
    role VARCHAR(50) NOT NULL DEFAULT 'moderator',
    permissions JSONB NOT NULL DEFAULT '{}',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- System Settings
CREATE TABLE IF NOT EXISTS system_settings (
    setting_id VARCHAR(36) PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) UNIQUE NOT NULL,
    value TEXT NOT NULL,
    value_type VARCHAR(50) DEFAULT 'string',
    category VARCHAR(100),
    description TEXT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_transactions_user_id ON transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_transactions_status ON transactions(status);
CREATE INDEX IF NOT EXISTS idx_transactions_created_at ON transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_stream_analytics_streamer_date ON stream_analytics(streamer_id, date DESC);
CREATE INDEX IF NOT EXISTS idx_analytics_events_user_type ON analytics_events(user_id, event_type);
CREATE INDEX IF NOT EXISTS idx_withdrawal_status ON withdrawal_requests(status, created_at DESC);

-- Default System Settings
INSERT INTO system_settings (key, value, value_type, category, description) VALUES
('coin_to_diamond_rate', '0.1', 'number', 'monetization', 'Rate to convert coins to diamonds'),
('min_withdrawal_amount', '10.00', 'number', 'monetization', 'Minimum withdrawal amount in USD'),
('max_withdrawal_amount', '10000.00', 'number', 'monetization', 'Maximum withdrawal amount in USD'),
('streamer_revenue_share', '0.70', 'number', 'monetization', 'Streamer revenue share percentage'),
('max_stream_duration_hours', '8', 'number', 'streaming', 'Maximum stream duration in hours'),
('max_file_upload_mb', '50', 'number', 'uploads', 'Maximum file upload size in MB'),
('ai_moderation_enabled', 'true', 'boolean', 'moderation', 'Enable AI content moderation'),
('maintenance_mode', 'false', 'boolean', 'system', 'Enable maintenance mode')
ON CONFLICT (key) DO NOTHING;

-- Default Subscription Plans
INSERT INTO subscription_plans (name, description, type, price, currency, features) VALUES
('Weekly Premium', 'Access premium features for 1 week', 'weekly', 2.99, 'USD', '{"badge": true, "exclusiveGifts": true, "hdStreaming": true}'),
('Monthly Premium', 'Access premium features for 1 month', 'monthly', 9.99, 'USD', '{"badge": true, "exclusiveGifts": true, "hdStreaming": true, "prioritySupport": true}'),
('Yearly Premium', 'Access premium features for 1 year', 'yearly', 79.99, 'USD', '{"badge": true, "exclusiveGifts": true, "hdStreaming": true, "prioritySupport": true, "vipBadge": true}')
ON CONFLICT DO NOTHING;
