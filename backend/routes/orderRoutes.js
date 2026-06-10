const express  = require('express');
const router   = express.Router();
const { placeOrder, getMyOrders, getOrderById, updateOrderStatus, cancelOrder } = require('../controllers/orderController');
const { protect } = require('../middleware/authMiddleware');

// Sab routes protected hain - JWT required
router.post('/',                  protect, placeOrder);         // Order place karo
router.get('/',                   protect, getMyOrders);        // Mere sare orders
router.get('/:id',                protect, getOrderById);       // Single order track
router.put('/:id/status',         protect, updateOrderStatus);  // Status update (admin)
router.put('/:id/cancel',         protect, cancelOrder);        // Cancel order

module.exports = router;
