'use strict';

const express = require('express');
const router = express.Router();

const v1Router = require('./v1');

// Health check
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Tutta API is running',
    timestamp: new Date().toISOString(),
  });
});

// API version 1
router.use('/v1', v1Router);

module.exports = router;
