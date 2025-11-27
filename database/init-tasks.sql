-- Initialize the tasks database
CREATE DATABASE IF NOT EXISTS todo_tasks;
USE todo_tasks;

-- Create tasks table with user association
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    user_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Insert some sample data
INSERT INTO tasks (title, completed) VALUES
('Learn React', false),
('Build a To-Do app', true),
('Deploy to production', false);
