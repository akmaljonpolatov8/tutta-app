'use strict';

/**
 * Application configuration derived from environment variables.
 */
const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT, 10) || 3000,
  jwtSecret: (() => {
    if (!process.env.JWT_SECRET) {
      if (process.env.NODE_ENV === 'production') {
        throw new Error('JWT_SECRET environment variable is required in production');
      }
      console.warn('[WARNING] JWT_SECRET is not set. Using insecure default – do NOT use in production.');
      return 'change-this-secret';
    }
    return process.env.JWT_SECRET;
  })(),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '7d',
};

module.exports = config;
