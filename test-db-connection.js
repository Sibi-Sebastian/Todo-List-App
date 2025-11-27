const mysql = require('mysql2/promise');

// Test database connection
async function testConnection() {
  console.log('🔍 Testing Database Connection...\n');

  const config = {
    host: 'localhost',
    user: 'root',
    password: 'sian',
    database: 'mysql', // Connect to mysql system database first
    port: 3306,
  };

  let connection;

  try {
    console.log('📡 Attempting to connect to MySQL...');
    connection = await mysql.createConnection(config);
    console.log('✅ Successfully connected to MySQL!\n');

    // Test creating databases
    console.log('🏗️  Creating databases...');

    // Create todo_tasks database
    await connection.execute('CREATE DATABASE IF NOT EXISTS todo_tasks');
    console.log('✅ Created todo_tasks database');

    // Create todo_users database
    await connection.execute('CREATE DATABASE IF NOT EXISTS todo_users');
    console.log('✅ Created todo_users database\n');

    // Test todo_tasks database
    await connection.execute('USE todo_tasks');
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS tasks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        completed BOOLEAN DEFAULT FALSE,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Created tasks table in todo_tasks database');

    // Insert sample data
    const [result] = await connection.execute(
      'INSERT INTO tasks (title, completed) VALUES (?, ?)',
      ['Sample Task from Direct DB Test', false]
    );
    console.log(`✅ Inserted sample task with ID: ${result.insertId}`);

    // Test retrieval
    const [rows] = await connection.execute('SELECT * FROM tasks ORDER BY created_at DESC LIMIT 5');
    console.log('📋 Retrieved tasks:', rows.length > 0 ? rows : 'No tasks found');

    // Test todo_users database
    await connection.execute('USE todo_users');
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        username VARCHAR(50) UNIQUE NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    console.log('✅ Created users table in todo_users database');

    console.log('\n🎉 Database setup and connection test completed successfully!');
    console.log('📊 Databases ready for application use.');

  } catch (error) {
    console.error('❌ Database connection failed:', error.message);

    // Try with wrong password to demonstrate
    console.log('\n🔍 Testing with wrong password...');
    const wrongConfig = { ...config, password: 'wrongpassword' };

    try {
      await mysql.createConnection(wrongConfig);
      console.log('⚠️  Unexpected: wrong password worked!');
    } catch (wrongPassError) {
      console.log('✅ Correctly rejected wrong password:', wrongPassError.message);
    }

  } finally {
    if (connection) {
      await connection.end();
      console.log('🔌 Database connection closed.');
    }
  }
}

// Run the test
testConnection().catch(console.error);
