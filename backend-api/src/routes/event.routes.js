const express = require('express');
const router = express.Router();
const { authenticate, optionalAuth } = require('../middlewares/auth.middleware');
const eventController = require('../controllers/event.controller');

router.get('/', optionalAuth, eventController.getEvents);
router.get('/featured', optionalAuth, eventController.getFeaturedEvents);
router.post('/', authenticate, eventController.createEvent);
router.get('/:eventId', optionalAuth, eventController.getEvent);
router.put('/:eventId', authenticate, eventController.updateEvent);
router.delete('/:eventId', authenticate, eventController.cancelEvent);
router.post('/:eventId/rsvp', authenticate, eventController.rsvpEvent);

module.exports = router;
