# Manual Testing Guide for To-Do List Application

This guide helps you manually test the To-Do List application after it's running.

## Prerequisites

1. Application is running via Docker Compose
2. All services are healthy (check with the automated tests first)

## Frontend Testing

### Access the Frontend
- URL: http://localhost:3000
- You should see the To-Do List interface

### Test Frontend Functionality

1. **Add a Task:**
   - Type "Test Task 1" in the input field
   - Click "Add Task" or press Enter
   - Task should appear in the list

2. **Mark Task as Complete:**
   - Click the checkbox next to the task
   - Task should show as completed (strikethrough text)

3. **Add Multiple Tasks:**
   - Add "Test Task 2" and "Test Task 3"
   - Verify all tasks appear

4. **Delete a Task:**
   - Click the "Delete" button next to any task
   - Task should be removed from the list

## API Testing

### Task Service API (http://localhost:3001)

#### Get All Tasks
```bash
curl http://localhost:3001/api/tasks
```
Expected: JSON array of tasks

#### Create a Task
```bash
curl -X POST http://localhost:3001/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Manual Test Task", "completed": false}'
```
Expected: JSON object with task details including ID

#### Update a Task (replace {id} with actual task ID)
```bash
curl -X PUT http://localhost:3001/api/tasks/{id} \
  -H "Content-Type: application/json" \
  -d '{"title": "Updated Manual Test Task", "completed": true}'
```
Expected: Updated JSON object

#### Delete a Task (replace {id} with actual task ID)
```bash
curl -X DELETE http://localhost:3001/api/tasks/{id}
```
Expected: 204 No Content

### User Service API (http://localhost:3002)

#### Register a User
```bash
curl -X POST http://localhost:3002/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "manualtest", "email": "manual@example.com", "password": "testpass123"}'
```
Expected: JSON with token and user details

#### Login
```bash
curl -X POST http://localhost:3002/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "manualtest", "password": "testpass123"}'
```
Expected: JSON with token and user details

#### Get Profile (replace {token} with actual token)
```bash
curl -H "Authorization: Bearer {token}" \
  http://localhost:3002/api/auth/profile
```
Expected: JSON with user profile

## Database Testing

### Access phpMyAdmin
- URL: http://localhost:8080
- Username: `root`
- Password: `password`

### Check Databases

1. **Tasks Database:**
   - Select "tasks-db" from server dropdown
   - Click on "todo_tasks" database
   - Check "tasks" table for your test data

2. **Users Database:**
   - Select "users-db" from server dropdown
   - Click on "todo_users" database
   - Check "users" table for registered users

## Health Checks

### Service Health Endpoints

#### Task Service Health
```bash
curl http://localhost:3001/health
```
Expected: `{"status": "OK", "service": "task-service"}`

#### User Service Health
```bash
curl http://localhost:3002/health
```
Expected: `{"status": "OK", "service": "user-service"}`

## Troubleshooting

### Common Issues

1. **Services not starting:**
   ```bash
   docker compose logs
   ```

2. **Ports already in use:**
   ```bash
   netstat -ano | findstr :3000
   # Kill the process using the port
   ```

3. **Database connection issues:**
   - Check if MySQL containers are running: `docker compose ps`
   - Check MySQL logs: `docker compose logs tasks-db users-db`

4. **API calls failing:**
   - Verify services are healthy first
   - Check for CORS issues in browser console

### Reset Everything

To start fresh:
```bash
# Stop and remove everything
docker compose down -v

# Start fresh
docker compose up -d --build
```
