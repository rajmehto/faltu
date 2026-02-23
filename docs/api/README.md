# Tango Live API Documentation

## Base URL
```
Production: https://api.tangolive.app/api/v1
Staging: https://staging-api.tangolive.app/api/v1
Development: http://localhost:3000/api/v1
```

## Authentication

All authenticated endpoints require a Bearer token in the Authorization header:
```
Authorization: Bearer <access_token>
```

Access tokens expire in 15 minutes. Use the refresh endpoint to get new tokens.

## Response Format

All responses follow this structure:
```json
{
  "success": true|false,
  "message": "Human readable message",
  "data": { ... } | [ ... ],
  "errors": { "field": "error message" }
}
```

## Pagination

Paginated responses include:
```json
{
  "items": [...],
  "total": 100,
  "page": 1,
  "pageSize": 20,
  "hasMore": true
}
```

## Rate Limits

| Endpoint Category | Limit |
|-------------------|-------|
| Global | 300 req/15min |
| Authentication | 10 req/15min |
| Stream Start | 5 req/hour |
| Gift Sending | 30 req/min |
| Chat Messages | 10 req/10sec |
| File Uploads | 30 req/hour |

## Endpoints Summary

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login
- `POST /auth/logout` - Logout
- `POST /auth/refresh` - Refresh tokens
- `POST /auth/social/login` - Social login (Google/Facebook/Apple)
- `POST /auth/phone/send-otp` - Send phone OTP
- `POST /auth/phone/verify-otp` - Verify phone OTP
- `POST /auth/forgot-password` - Forgot password
- `POST /auth/reset-password` - Reset password
- `POST /auth/2fa/enable` - Enable 2FA
- `POST /auth/2fa/verify` - Verify 2FA

### Streaming
- `POST /streams/start` - Start live stream
- `POST /streams/end` - End live stream
- `GET /streams/live` - Get live streams
- `GET /streams/trending` - Get trending streams
- `GET /streams/nearby` - Get nearby streams
- `GET /streams/recommended` - Personalized recommendations
- `GET /streams/search` - Search streams
- `GET /streams/:streamId` - Get stream details
- `POST /streams/:streamId/join` - Join stream
- `POST /streams/:streamId/leave` - Leave stream

### See docs/api/ directory for full documentation

## WebSocket Events

Connect to WebSocket server at the `wsBaseUrl` with Bearer token in auth.

### Emit Events
- `stream:join` - Join stream room
- `stream:leave` - Leave stream room
- `chat:send` - Send chat message
- `gift:send` - Send virtual gift
- `reaction:send` - Send reaction emoji

### Listen Events
- `chat:message:{streamId}` - New chat message
- `gift:received:{streamId}` - Gift animation
- `stream:viewers:{streamId}` - Viewer count update
- `user:joined:{streamId}` - User joined
- `user:left:{streamId}` - User left
- `stream:ended:{streamId}` - Stream ended
- `notification` - Push notification

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request / Validation Error |
| 401 | Unauthorized / Token expired |
| 403 | Forbidden / Banned |
| 404 | Not Found |
| 429 | Rate Limited |
| 500 | Internal Server Error |
