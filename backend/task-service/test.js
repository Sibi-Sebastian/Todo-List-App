const http = require('http');

const baseUrl = 'localhost';
const port = 3001;

// Helper function to make HTTP requests
function makeRequest(options, data = null) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let body = '';
      res.on('data', (chunk) => {
        body += chunk;
      });
      res.on('end', () => {
        try {
          const parsedBody = body ? JSON.parse(body) : {};
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: parsedBody
          });
        } catch (e) {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: body
          });
        }
      });
    });

    req.on('error', (err) => {
      reject(err);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }
    req.end();
  });
}

// Test functions
async function testHealthCheck() {
  console.log('🩺 Testing Health Check...');
  try {
    const response = await makeRequest({
      hostname: baseUrl,
      port: port,
      path: '/health',
      method: 'GET'
    });

    if (response.statusCode === 200 && response.body.status === 'OK') {
      console.log('✅ Health check passed');
      return true;
    } else {
      console.log('❌ Health check failed');
      return false;
    }
  } catch (error) {
    console.log('❌ Health check error:', error.message);
    return false;
  }
}

async function testGetTasks() {
  console.log('📋 Testing Get All Tasks...');
  try {
    const response = await makeRequest({
      hostname: baseUrl,
      port: port,
      path: '/api/tasks',
      method: 'GET'
    });

    if (response.statusCode === 200 && Array.isArray(response.body)) {
      console.log('✅ Get tasks passed');
      return true;
    } else {
      console.log('❌ Get tasks failed');
      return false;
    }
  } catch (error) {
    console.log('❌ Get tasks error:', error.message);
    return false;
  }
}

async function testCreateTask() {
  console.log('➕ Testing Create Task...');
  try {
    const newTask = {
      title: 'Test Task from Unit Test',
      completed: false
    };

    const response = await makeRequest({
      hostname: baseUrl,
      port: port,
      path: '/api/tasks',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      }
    }, newTask);

    if (response.statusCode === 201 && response.body.id) {
      console.log('✅ Create task passed');
      return response.body.id;
    } else {
      console.log('❌ Create task failed');
      return null;
    }
  } catch (error) {
    console.log('❌ Create task error:', error.message);
    return null;
  }
}

async function testUpdateTask(taskId) {
  console.log('✏️  Testing Update Task...');
  try {
    const updatedTask = {
      title: 'Updated Test Task',
      completed: true
    };

    const response = await makeRequest({
      hostname: baseUrl,
      port: port,
      path: `/api/tasks/${taskId}`,
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      }
    }, updatedTask);

    if (response.statusCode === 200 && response.body.completed === true) {
      console.log('✅ Update task passed');
      return true;
    } else {
      console.log('❌ Update task failed');
      return false;
    }
  } catch (error) {
    console.log('❌ Update task error:', error.message);
    return false;
  }
}

async function testDeleteTask(taskId) {
  console.log('🗑️  Testing Delete Task...');
  try {
    const response = await makeRequest({
      hostname: baseUrl,
      port: port,
      path: `/api/tasks/${taskId}`,
      method: 'DELETE'
    });

    if (response.statusCode === 204) {
      console.log('✅ Delete task passed');
      return true;
    } else {
      console.log('❌ Delete task failed');
      return false;
    }
  } catch (error) {
    console.log('❌ Delete task error:', error.message);
    return false;
  }
}

// Run all tests
async function runAllTests() {
  console.log('🚀 Starting Task Service Tests\n');

  // Test health check
  const healthOk = await testHealthCheck();

  if (!healthOk) {
    console.log('\n❌ Service is not running. Please start the service first.');
    console.log('Run: npm start');
    return;
  }

  // Test get tasks
  await testGetTasks();

  // Test create task
  const taskId = await testCreateTask();

  if (taskId) {
    // Test update task
    await testUpdateTask(taskId);

    // Test delete task
    await testDeleteTask(taskId);
  }

  console.log('\n🎉 Task Service tests completed!');
}

// Export for use as module or run directly
if (require.main === module) {
  runAllTests().catch(console.error);
}

module.exports = {
  testHealthCheck,
  testGetTasks,
  testCreateTask,
  testUpdateTask,
  testDeleteTask,
  runAllTests
};
