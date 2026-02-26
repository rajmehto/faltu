const express = require('express');
const router = express.Router();
const { authenticate, requireRole } = require('../middlewares/auth.middleware');
const adminController = require('../controllers/admin.controller');

const isAdmin = [authenticate, requireRole('super_admin', 'admin', 'moderator')];

router.get('/dashboard', isAdmin, adminController.getDashboardStats);
router.get('/users', isAdmin, adminController.getUsers);
router.post('/users/:userId/ban', isAdmin, adminController.banUser);
router.delete('/users/:userId/ban', isAdmin, adminController.unbanUser);
router.get('/reports', isAdmin, adminController.getReports);
router.put('/reports/:reportId', isAdmin, adminController.resolveReport);
router.get('/streams/live', isAdmin, adminController.getLiveStreams);
router.post('/streams/:streamId/terminate', isAdmin, adminController.terminateStream);
router.post('/reports', authenticate, adminController.submitReport);

module.exports = router;
