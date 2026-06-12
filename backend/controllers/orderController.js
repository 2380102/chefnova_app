const db = require('../config/db');

// ===================== PLACE ORDER =====================
const placeOrder = async (req, res) => {
  try {
    const user_id = req.user.id; // JWT se milta hai
    const { recipe_id, quantity, total_price, payment_method, delivery_address, notes } = req.body;

    if (!recipe_id || !quantity || total_price === undefined || total_price === null || !payment_method) {
      return res.status(400).json({
        success: false,
        message: 'recipe_id, quantity, total_price aur payment_method required hain'
      });
    }

    // Validate payment method
    const validPayments = ['cash', 'card', 'easypaisa', 'jazzcash'];
    if (!validPayments.includes(payment_method.toLowerCase())) {
      return res.status(400).json({
        success: false,
        message: `Payment method valid nahi. Yeh options hain: ${validPayments.join(', ')}`
      });
    }

    // Recipe exist check
    const [recipe] = await db.query('SELECT id, name FROM recipes WHERE id = ?', [recipe_id]);
    if (recipe.length === 0) {
      return res.status(404).json({ success: false, message: 'Recipe nahi mili' });
    }

    const [result] = await db.query(
      `INSERT INTO orders (user_id, recipe_id, quantity, total_price, payment_method, delivery_address, notes)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [user_id, recipe_id, quantity, total_price, payment_method.toLowerCase(), delivery_address || '', notes || '']
    );

    res.status(201).json({
      success: true,
      message: 'Order place ho gaya!',
      order_id: result.insertId,
      status: 'pending',
      recipe: recipe[0].name,
      payment_method: payment_method.toLowerCase()
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== MY ORDERS (tracking) =====================
const getMyOrders = async (req, res) => {
  try {
    const user_id = req.user.id;

    const [rows] = await db.query(
      `SELECT o.id, o.quantity, o.total_price, o.payment_method,
              o.status, o.delivery_address, o.notes,
              o.created_at, o.updated_at,
              r.name AS recipe_name, r.emoji, r.category
       FROM orders o
       JOIN recipes r ON o.recipe_id = r.id
       WHERE o.user_id = ?
       ORDER BY o.created_at DESC`,
      [user_id]
    );

    res.json({ success: true, total: rows.length, data: rows });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== SINGLE ORDER TRACK =====================
const getOrderById = async (req, res) => {
  try {
    const user_id = req.user.id;
    const order_id = req.params.id;

    const [rows] = await db.query(
      `SELECT o.*, r.name AS recipe_name, r.emoji, r.category
       FROM orders o
       JOIN recipes r ON o.recipe_id = r.id
       WHERE o.id = ? AND o.user_id = ?`,
      [order_id, user_id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Order nahi mila ya aap ka nahi hai' });
    }

    const order = rows[0];

    // Status stages
    const stages = ['pending', 'confirmed', 'preparing', 'on_the_way', 'delivered'];
    const currentIndex = stages.indexOf(order.status);

    res.json({
      success: true,
      data: {
        ...order,
        tracking: {
          current_status: order.status,
          stages: stages.map((s, i) => ({
            stage: s,
            completed: i <= currentIndex && order.status !== 'cancelled'
          }))
        }
      }
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== UPDATE ORDER STATUS (Admin use) =====================
const updateOrderStatus = async (req, res) => {
  try {
    const { status } = req.body;
    const validStatuses = ['pending', 'confirmed', 'preparing', 'on_the_way', 'delivered', 'cancelled'];

    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Valid statuses: ${validStatuses.join(', ')}`
      });
    }

    const [result] = await db.query(
      'UPDATE orders SET status = ? WHERE id = ?',
      [status, req.params.id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ success: false, message: 'Order nahi mila' });
    }

    res.json({ success: true, message: `Order status update hua: ${status}` });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== CANCEL ORDER =====================
const cancelOrder = async (req, res) => {
  try {
    const user_id = req.user.id;

    const [rows] = await db.query(
      'SELECT status FROM orders WHERE id = ? AND user_id = ?',
      [req.params.id, user_id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Order nahi mila' });
    }

    if (['delivered', 'cancelled'].includes(rows[0].status)) {
      return res.status(400).json({
        success: false,
        message: `Order pehle se ${rows[0].status} hai, cancel nahi ho sakta`
      });
    }

    await db.query('UPDATE orders SET status = ? WHERE id = ?', ['cancelled', req.params.id]);

    res.json({ success: true, message: 'Order cancel ho gaya' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { placeOrder, getMyOrders, getOrderById, updateOrderStatus, cancelOrder };
