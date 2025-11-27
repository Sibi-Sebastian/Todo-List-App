// Database configuration
const config = {
  db: {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'sian',
    database: process.env.DB_NAME || 'todo_tasks',
    port: process.env.DB_PORT || 3306,
  },
  server: {
    port: process.env.PORT || 3001,
  },
};

module.exports = config;
