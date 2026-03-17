'use strict';

/**
 * Authentication middleware (JWT verification placeholder).
 * Replace with actual JWT verification once auth is implemented.
 */
const authenticate = (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Unauthorized – no token provided' });
  }

  // TODO: verify JWT token
  next();
};

module.exports = { authenticate };
