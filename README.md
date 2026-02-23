# 🎥 Tango Live - Complete Live Streaming App

A comprehensive Tango Live-style live streaming application for Android & iOS with all advanced features.

## 🚀 Features

### 📡 Live Streaming
- HD live streaming via Agora.io (360p/720p/1080p)
- Co-hosting with up to 5 guests
- Screen sharing
- Background music
- Stream recording & replays
- Virtual backgrounds
- Stream scheduling
- Multi-stream support

### 💬 Real-Time Interaction
- Live chat with emoji, stickers, GIFs
- Super Chat (paid highlighted messages)
- @mentions and hashtags
- Direct messaging
- Chat moderation tools
- Pinned messages
- Message reactions

### 🎁 Virtual Gifts & Monetization
- 50+ animated virtual gifts (roses, cars, luxury items)
- Lottie animations for gift effects
- Gift leaderboards (daily, weekly, monthly)
- Coin purchase system (Stripe, Razorpay, Apple/Google Pay)
- Diamond earning system
- Streamer revenue sharing (70%)
- Withdrawal system (PayPal, bank transfer, UPI)
- Super Chat revenue
- Subscription tiers (Weekly/Monthly/Yearly)

### 👤 Social Features  
- Follow/Unfollow
- Friend suggestions
- Activity feed
- User profiles with stats
- Stories
- Hashtag discovery
- Social media sharing

### ✨ Beauty & AR Filters
- Skin smoothing
- Face slimming
- AR stickers and masks
- Color filters
- Virtual background replacement
- Multiple filter presets

### 🤖 AI Features
- Content moderation (NSFW detection)
- Auto-generated captions
- Real-time translation
- Smart reply suggestions
- Spam detection
- Recommendation algorithm

### 📊 Analytics
- Real-time viewer count
- Stream performance metrics
- Audience demographics
- Revenue analytics
- Engagement metrics (likes, shares, comments)
- Historical reports

### 🏆 Gamification
- XP and leveling system (level up by streaming/gifting)
- Achievement badges (50+ achievements)
- Daily challenges
- Leaderboards (gifters, streamers, viewers)
- Seasonal events

### 🎤 Voice Rooms & Party
- Voice-only chat rooms
- Speaker/listener roles
- Room moderation
- Party games integration

### 🎵 Background Music
- Licensed music library
- Background music during streams
- Song request system

### 📅 Events & Tournaments
- Event calendar
- RSVP system
- Tournament brackets
- Featured events
- Event rewards

### 🛡️ Safety & Moderation
- AI + human moderation
- Report system
- Ban/mute tools
- Content policies
- Age verification
- NSFW filter

### 🔔 Notifications
- Push notifications (FCM)
- In-app notifications  
- Follow/gift/mention alerts
- Stream start notifications

### 💼 Admin Dashboard
- User management
- Stream monitoring
- Financial reports
- Content moderation queue
- System settings

## 🏗️ Architecture

### Mobile App (Flutter)
```
mobile-app/
├── lib/
│   ├── core/          # Config, themes, constants, network
│   ├── data/          # Models, repositories, data sources
│   ├── domain/        # Business entities and use cases
│   ├── presentation/  # Pages, widgets, controllers
│   └── services/      # Agora, Socket.io, Firebase, Payment
```

### Backend (Node.js)
```
backend-api/
├── src/
│   ├── config/        # Database, Redis, Firebase
│   ├── controllers/   # Request handlers
│   ├── models/        # Mongoose models
│   ├── routes/        # Express routes
│   ├── services/      # Business logic
│   ├── middlewares/   # Auth, rate limit, validation
│   └── websocket/     # Socket.io handlers
```

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter 3.x + Dart |
| State Management | GetX + Bloc |
| Backend API | Node.js + Express |
| Real-time | Socket.io |
| Streaming | Agora.io |
| Primary DB | MongoDB |
| Relational DB | PostgreSQL |
| Cache | Redis |
| Auth | Firebase Auth + JWT |
| Storage | Firebase Storage + AWS S3 |
| Payments | Stripe + Razorpay |
| Push Notifications | Firebase Cloud Messaging |
| AI | OpenAI + Google Cloud AI |
| Infrastructure | Docker + Kubernetes + Nginx |

## 🚦 Quick Start

### Prerequisites
- Flutter SDK 3.x
- Node.js 18+
- MongoDB 7.0
- PostgreSQL 16
- Redis 7.2
- Agora.io account
- Firebase project

### Backend Setup
```bash
cd backend-api
cp .env.example .env
# Edit .env with your credentials
npm install
npm run dev
```

### Flutter App Setup
```bash
cd mobile-app
flutter pub get
flutter run
```

### Docker Setup
```bash
cd infrastructure/docker
docker-compose up -d
```

## 📱 Environment Configuration

Create `backend-api/.env` from `backend-api/.env.example` and fill in:
- Database connection strings
- Agora App ID and Certificate
- Firebase service account JSON
- Stripe and Razorpay API keys
- Twilio credentials for SMS
- SMTP credentials for email

For Flutter, set environment variables via `--dart-define`:
```bash
flutter run \
  --dart-define=ENV=development \
  --dart-define=AGORA_APP_ID=your_agora_app_id \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

## 📄 Documentation

- [API Documentation](docs/api/README.md)
- [Architecture Guide](docs/architecture/README.md)
- [Deployment Guide](docs/deployment/)
- [User Guides](docs/user-guides/)

## 📊 Supported Platforms

- ✅ Android (API 21+)
- ✅ iOS (iOS 13+)
- ✅ Web (Progressive)

## 🔐 Security Features

- JWT with short-lived access tokens (15min)
- Refresh token rotation
- 2FA (TOTP)
- Rate limiting per endpoint
- Input validation and sanitization
- HTTPS enforcement
- CORS configuration
- Helmet security headers
- SQL injection prevention
- XSS protection

## 📝 License

This project is proprietary software. All rights reserved.
