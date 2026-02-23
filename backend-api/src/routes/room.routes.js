const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
router.get('/', optionalAuth, (req, res) => res.json({ success: true, data: [], message: 'room endpoint' }));
module.exports = router;
