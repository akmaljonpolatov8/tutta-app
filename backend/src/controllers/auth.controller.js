'use strict';

/**
 * @desc    Register a new user
 * @route   POST /api/v1/auth/register
 * @access  Public
 */
const register = (req, res) => {
  res.status(201).json({ success: true, message: 'Register endpoint – coming soon' });
};

/**
 * @desc    Login a user
 * @route   POST /api/v1/auth/login
 * @access  Public
 */
const login = (req, res) => {
  res.status(200).json({ success: true, message: 'Login endpoint – coming soon' });
};

module.exports = { register, login };
