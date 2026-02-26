const express = require('express');
const router = express.Router();

router.get('/health', (req, res) => {
  res.json({
    success: true,
    data: {
      status: 'healthy',
      timestamp: new Date().toISOString(),
      uptime: process.uptime(),
      environment: process.env.NODE_ENV,
    },
  });
});

router.get('/version', (req, res) => {
  res.json({ success: true, data: { version: '1.0.0', api: 'v1' } });
});

module.exports = router;
