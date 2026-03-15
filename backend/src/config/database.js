'use strict';

/**
 * Database configuration.
 * Uses environment variables defined in .env
 */
const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  database: process.env.DB_NAME || 'tutta',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
};

module.exports = dbConfig;
