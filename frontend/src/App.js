import React, { useState, useEffect } from 'react';
import { AuthProvider, useAuth } from './AuthContext';
import Login from './Login';
import Register from './Register';
import './App.css';

// Task Management Component (shown when authenticated)
const TaskManager = () => {
  const [tasks, setTasks] = useState([]);
  const [newTask, setNewTask] = useState('');
  const [loading, setLoading] = useState(false);
  const { user, getAuthHeaders, logout } = useAuth();

  // Fetch tasks from backend
  useEffect(() => {
    fetchTasks();
  }, []);

  const fetchTasks = async () => {
    try {
      setLoading(true);
      const response = await fetch('http://localhost:3001/api/tasks', {
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        const data = await response.json();
        setTasks(data);
      } else if (response.status === 401) {
        // Token expired, logout
        logout();
      }
    } catch (error) {
      console.error('Error fetching tasks:', error);
    } finally {
      setLoading(false);
    }
  };

  const addTask = async () => {
    if (newTask.trim() === '') return;

    try {
      const response = await fetch('http://localhost:3001/api/tasks', {
        method: 'POST',
        headers: getAuthHeaders(),
        body: JSON.stringify({
          title: newTask,
          completed: false,
        }),
      });

      if (response.ok) {
        const task = await response.json();
        setTasks([...tasks, task]);
        setNewTask('');
      } else if (response.status === 401) {
        logout();
      }
    } catch (error) {
      console.error('Error adding task:', error);
    }
  };

  const toggleTask = async (id) => {
    try {
      const task = tasks.find(t => t.id === id);
      const response = await fetch(`http://localhost:3001/api/tasks/${id}`, {
        method: 'PUT',
        headers: getAuthHeaders(),
        body: JSON.stringify({
          title: task.title,
          completed: !task.completed,
        }),
      });

      if (response.ok) {
        const updatedTask = await response.json();
        setTasks(tasks.map(t => t.id === id ? updatedTask : t));
      } else if (response.status === 401) {
        logout();
      }
    } catch (error) {
      console.error('Error updating task:', error);
    }
  };

  const deleteTask = async (id) => {
    try {
      const response = await fetch(`http://localhost:3001/api/tasks/${id}`, {
        method: 'DELETE',
        headers: getAuthHeaders(),
      });

      if (response.ok) {
        setTasks(tasks.filter(t => t.id !== id));
      } else if (response.status === 401) {
        logout();
      }
    } catch (error) {
      console.error('Error deleting task:', error);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter') {
      addTask();
    }
  };

  return (
    <div className="App">
      <header className="App-header">
        <div className="app-header">
          <h1>To-Do List App</h1>
          <div className="user-info">
            <span>Welcome, {user?.username}!</span>
            <button onClick={logout} className="logout-btn">Logout</button>
          </div>
        </div>

        <div className="task-input">
          <input
            type="text"
            value={newTask}
            onChange={(e) => setNewTask(e.target.value)}
            onKeyPress={handleKeyPress}
            placeholder="Enter a new task..."
          />
          <button onClick={addTask}>Add Task</button>
        </div>

        {loading ? (
          <p>Loading tasks...</p>
        ) : (
          <div className="task-list">
            {tasks.length === 0 ? (
              <p>No tasks yet. Add one above!</p>
            ) : (
              tasks.map(task => (
                <div key={task.id} className={`task-item ${task.completed ? 'completed' : ''}`}>
                  <input
                    type="checkbox"
                    checked={task.completed}
                    onChange={() => toggleTask(task.id)}
                  />
                  <span className="task-title">{task.title}</span>
                  <button onClick={() => deleteTask(task.id)} className="delete-btn">Delete</button>
                </div>
              ))
            )}
          </div>
        )}
      </header>
    </div>
  );
};

// Main App Component
function App() {
  const [showRegister, setShowRegister] = useState(false);
  const { isAuthenticated, loading } = useAuth();

  // Show loading spinner while checking authentication
  if (loading) {
    return (
      <div className="App">
        <div className="loading">
          <h2>Loading...</h2>
        </div>
      </div>
    );
  }

  // Show login/register forms if not authenticated
  if (!isAuthenticated()) {
    return showRegister ? (
      <Register onSwitchToLogin={() => setShowRegister(false)} />
    ) : (
      <Login onSwitchToRegister={() => setShowRegister(true)} />
    );
  }

  // Show task manager if authenticated
  return <TaskManager />;
}

// Wrap App with AuthProvider
function AppWithAuth() {
  return (
    <AuthProvider>
      <App />
    </AuthProvider>
  );
}

export default AppWithAuth;
