const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'chefnova_secret_key_2024';

const protect = (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return res.status(401).json({ success: false, message: 'Access denied. Token nahi mila. Pehle login karein.' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    req.user = decoded; // { id, name, email }
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid ya expired token. Dobara login karein.' });
  }
};

module.exports = { protect, JWT_SECRET };
