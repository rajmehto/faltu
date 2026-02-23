# Tango Live - Architecture Documentation

## System Overview

Tango Live is a microservices-based live streaming platform built for scale.

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                             │
│  Flutter Mobile App (Android/iOS)  │  Web Admin Dashboard      │
└─────────────────┬───────────────────────────────────────────────┘
                  │ HTTPS/WSS
┌─────────────────▼───────────────────────────────────────────────┐
│                    NGINX (Load Balancer + SSL)                   │
└──────┬────────────────────────────────────────┬─────────────────┘
       │                                        │
┌──────▼──────┐                        ┌───────▼──────┐
│  REST API   │                        │  WebSocket   │
│  (Express)  │                        │  (Socket.io) │
└──────┬──────┘                        └───────┬──────┘
       │                                        │
┌──────▼────────────────────────────────────────▼─────────────────┐
│                    SERVICE LAYER                                 │
│  Auth │ Stream │ Chat │ Gift │ Wallet │ Payment │ Analytics     │
└──┬────┴────┬───┴──────┴──────┴────────┴─────────┴──────────────┘
   │         │
┌──▼─────────▼──────────────────────────────────────────────────┐
│                    DATA LAYER                                   │
│  MongoDB (NoSQL)  │  PostgreSQL  │  Redis (Cache/PubSub)      │
└───────────────────────────────────────────────────────────────┘
       │
┌──────▼────────────────────────────────────────────────────────┐
│                EXTERNAL SERVICES                               │
│  Agora (Streaming) │ Firebase │ Stripe │ Razorpay │ Twilio   │
│  AWS S3 (Storage)  │ OpenAI   │ Sentry │ SendGrid             │
└───────────────────────────────────────────────────────────────┘
```

## Core Services

### Backend API (Node.js + Express)
- RESTful API for all client operations
- JWT-based authentication with refresh tokens
- Rate limiting and request validation
- File upload handling

### Real-time Service (Socket.io)
- Live chat messages
- Gift animations
- Viewer count updates
- Notifications

### Streaming (Agora.io)
- Live video/audio streaming
- Multi-host support (co-hosting)
- Screen sharing
- Background music

### Databases
- **MongoDB**: User profiles, streams, chat, gifts, rooms, events
- **PostgreSQL**: Wallets, transactions, subscriptions, analytics
- **Redis**: Sessions, caching, rate limiting, pub/sub, leaderboards

## Key Design Decisions

1. **Clean Architecture** in Flutter app (Domain/Data/Presentation layers)
2. **GetX** for state management (reactive, simple, performant)
3. **Agora.io** for streaming (reliable, global infrastructure)
4. **Firebase** for authentication, push notifications, analytics
5. **Stripe + Razorpay** for global + regional payments
6. **Redis** for real-time leaderboards and caching
7. **Socket.io** for bidirectional real-time communication

## Scalability Approach

- Horizontal scaling via Docker + Kubernetes
- Redis pub/sub for multi-server WebSocket coordination  
- CDN for static assets and video delivery
- MongoDB read replicas for heavy read workloads
- Background job queues (Bull + Redis) for async tasks
