const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const musicController = require('../controllers/music.controller');

router.get('/', optionalAuth, musicController.getMusicList);
router.get('/genres', optionalAuth, musicController.getGenres);
router.get('/trending', optionalAuth, musicController.getTrending);
router.get('/:musicId', optionalAuth, musicController.getMusicById);
router.post('/stream/:streamId', authenticate, musicController.setStreamMusic);

module.exports = router;
