'use strict';

const express = require('express');
const router = express.Router();

const authController = require('../controllers/auth.controller');
const listingsController = require('../controllers/listings.controller');

// Auth routes
router.post('/auth/register', authController.register);
router.post('/auth/login', authController.login);

// Listings routes
router.get('/listings', listingsController.getAll);
router.get('/listings/:id', listingsController.getById);

module.exports = router;
