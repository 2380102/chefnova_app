const db      = require('../config/db');
const bcrypt  = require('bcryptjs');
const jwt     = require('jsonwebtoken');
const { JWT_SECRET } = require('../middleware/authMiddleware');

// ===================== SIGNUP =====================
const signup = async (req, res) => {
  try {
    const { name, email, phone, address, password } = req.body;

    if (!name || !email || !phone || !password) {
      return res.status(400).json({
        success: false,
        message: 'name, email, phone aur password sab required hain'
      });
    }

    const [existing] = await db.query('SELECT id FROM users WHERE email = ?', [email]);
    if (existing.length > 0) {
      return res.status(409).json({ success: false, message: 'Yeh email pehle se registered hai' });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const [result] = await db.query(
      'INSERT INTO users (name, email, phone, address, password) VALUES (?, ?, ?, ?, ?)',
      [name, email, phone, address || '', hashedPassword]
    );

    const token = jwt.sign(
      { id: result.insertId, name, email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.status(201).json({
      success: true,
      message: 'Account create ho gaya!',
      token,
      user: { id: result.insertId, name, email, phone, address: address || '' }
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== LOGIN =====================
const login = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ success: false, message: 'Email aur password required hain' });
    }

    const [rows] = await db.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length === 0) {
      return res.status(401).json({ success: false, message: 'Email ya password ghalat hai' });
    }

    const user = rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ success: false, message: 'Email ya password ghalat hai' });
    }

    const token = jwt.sign(
      { id: user.id, name: user.name, email: user.email },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({
      success: true,
      message: 'Login successful!',
      token,
      user: { id: user.id, name: user.name, email: user.email, phone: user.phone, address: user.address || '' }
    });

  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== GET MY PROFILE =====================
const getProfile = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT id, name, email, phone, address, created_at FROM users WHERE id = ?',
      [req.user.id]
    );
    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'User nahi mila' });
    }
    res.json({ success: true, data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

// ===================== UPDATE PROFILE =====================
const updateProfile = async (req, res) => {
  try {
    const { name, phone, address } = req.body;
    await db.query(
      'UPDATE users SET name = ?, phone = ?, address = ? WHERE id = ?',
      [name || '', phone || '', address || '', req.user.id]
    );
    const [rows] = await db.query(
      'SELECT id, name, email, phone, address FROM users WHERE id = ?',
      [req.user.id]
    );
    res.json({ success: true, message: 'Profile update ho gaya!', data: rows[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

module.exports = { signup, login, getProfile, updateProfile };
