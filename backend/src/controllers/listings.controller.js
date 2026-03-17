'use strict';

/**
 * @desc    Get all listings
 * @route   GET /api/v1/listings
 * @access  Public
 */
const getAll = (req, res) => {
  res.status(200).json({ success: true, message: 'Get all listings – coming soon', data: [] });
};

/**
 * @desc    Get a single listing by ID
 * @route   GET /api/v1/listings/:id
 * @access  Public
 */
const getById = (req, res) => {
  res.status(200).json({ success: true, message: `Get listing ${req.params.id} – coming soon`, data: null });
};

module.exports = { getAll, getById };
