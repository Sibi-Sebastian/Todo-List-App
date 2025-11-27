const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const config = require('./config');

const app = express();
const PORT = config.server.port;

// JWT Secret (should match user service)
const JWT_SECRET = process.env.JWT_SECRET || 'your-super-secret-jwt-key-change-in-production';

// Middleware
app.use(cors());
app.use(express.json());

// JWT Authentication Middleware
const authenticateToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({ error: 'Access token required' });
  }

  jwt.verify(token, JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid or expired token' });
    }
    req.user = user;
    next();
  });
};

// Database connection
let db;

async function connectToDatabase() {
  try {
    db = await mysql.createConnection(config.db);
    console.log('Connected to MySQL database');

    // Create tasks table if it doesn't exist (with user_id)
    await db.execute(`
      CREATE TABLE IF NOT EXISTS tasks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        completed BOOLEAN DEFAULT FALSE,
        user_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('Tasks table ready');
  } catch (error) {
    console.error('Database connection failed:', error);
    process.exit(1);
  }
}

// Routes (all protected by authentication)
app.get('/api/tasks', authenticateToken, async (req, res) => {
  try {
    const [rows] = await db.execute(
      'SELECT id, title, completed, created_at FROM tasks WHERE user_id = ? ORDER BY created_at DESC',
      [req.user.user_id]
    );
    res.json(rows);
  } catch (error) {
    console.error('Error fetching tasks:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.post('/api/tasks', authenticateToken, async (req, res) => {
  try {
    const { title, completed = false } = req.body;

    if (!title || title.trim() === '') {
      return res.status(400).json({ error: 'Title is required' });
    }

    const [result] = await db.execute(
      'INSERT INTO tasks (title, completed, user_id) VALUES (?, ?, ?)',
      [title.trim(), completed, req.user.user_id]
    );

    const [rows] = await db.execute(
      'SELECT id, title, completed, created_at FROM tasks WHERE id = ?',
      [result.insertId]
    );
    res.status(201).json(rows[0]);
  } catch (error) {
    console.error('Error creating task:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.put('/api/tasks/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;
    const { title, completed } = req.body;

    // Check if task exists and belongs to user
    const [existing] = await db.execute(
      'SELECT * FROM tasks WHERE id = ? AND user_id = ?',
      [id, req.user.user_id]
    );
    if (existing.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const updateFields = [];
    const updateValues = [];

    if (title !== undefined) {
      updateFields.push('title = ?');
      updateValues.push(title.trim());
    }

    if (completed !== undefined) {
      updateFields.push('completed = ?');
      updateValues.push(completed);
    }

    if (updateFields.length === 0) {
      return res.status(400).json({ error: 'No valid fields to update' });
    }

    updateValues.push(id, req.user.user_id);

    await db.execute(
      `UPDATE tasks SET ${updateFields.join(', ')} WHERE id = ? AND user_id = ?`,
      updateValues
    );

    const [rows] = await db.execute(
      'SELECT id, title, completed, created_at FROM tasks WHERE id = ?',
      [id]
    );
    res.json(rows[0]);
  } catch (error) {
    console.error('Error updating task:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

app.delete('/api/tasks/:id', authenticateToken, async (req, res) => {
  try {
    const { id } = req.params;

    // Check if task exists and belongs to user
    const [existing] = await db.execute(
      'SELECT * FROM tasks WHERE id = ? AND user_id = ?',
      [id, req.user.user_id]
    );
    if (existing.length === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    const [result] = await db.execute(
      'DELETE FROM tasks WHERE id = ? AND user_id = ?',
      [id, req.user.user_id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Task not found' });
    }

    res.status(204).send();
  } catch (error) {
    console.error('Error deleting task:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', service: 'task-service' });
});

// Start server
async function startServer() {
  await connectToDatabase();

  app.listen(PORT, () => {
    console.log(`Task Service running on port ${PORT}`);
  });
}

startServer().catch(console.error);
