# To-Do List Microservices Application

A full-stack To-Do List application built with microservices architecture, featuring separate services for tasks and user management, containerized with Docker.

## Architecture

The application consists of the following microservices:

### Frontend (React)
- **Port**: 3000
- **Technology**: React 18
- **Features**:
  - Task list display
  - Add new tasks
  - Mark tasks as complete/incomplete
  - Delete tasks
  - Clean, responsive UI

### Backend Services

#### Task Service (Node.js)
- **Port**: 3001
- **Technology**: Node.js + Express
- **Database**: MySQL (todo_tasks)
- **Features**:
  - REST API for CRUD operations on tasks
  - MySQL database integration
  - CORS enabled

#### User Service (Python/Flask)
- **Port**: 3002
- **Technology**: Python + Flask
- **Database**: MySQL (todo_users)
- **Features**:
  - User registration and authentication
  - JWT token-based authentication
  - Password hashing with bcrypt

### Databases
- **Tasks Database**: MySQL on port 3307
- **Users Database**: MySQL on port 3308
- **phpMyAdmin**: Available on port 8080 for database management

## Project Structure

```
todoListApp/
├── frontend/                 # React frontend
│   ├── src/
│   ├── Dockerfile
│   └── nginx.conf
├── backend/
│   ├── task-service/         # Node.js task service
│   │   ├── index.js
│   │   ├── config.js
│   │   └── Dockerfile
│   └── user-service/         # Python user service
│       ├── app.py
│       ├── config.py
│       └── Dockerfile
├── database/                 # Database initialization scripts
│   ├── init-tasks.sql
│   └── init-users.sql
├── docker-compose.yml         # Docker orchestration
└── README.md
```

## Prerequisites

- **Docker and Docker Compose** installed
  - Download Docker Desktop from: https://www.docker.com/products/docker-desktop
  - Make sure Docker is running
- At least 4GB RAM available for containers
- Ports 3000-3002, 3307-3308, 8080 available

### Installing Docker on Windows

1. Download Docker Desktop from the link above
2. Run the installer and follow the setup wizard
3. Start Docker Desktop after installation
4. Wait for Docker to fully start (you'll see the Docker icon in system tray)

## Quick Start

1. **Clone and navigate to the project directory**
   ```bash
   cd todoListApp
   ```

2. **Start all services**
   ```bash
   docker compose up --build -d
   ```

3. **Access the application**
   - **Frontend**: http://localhost:3000
   - **phpMyAdmin**: http://localhost:8080
     - Server: tasks-db (for tasks) or users-db (for users)
     - Username: root
     - Password: password

4. **Stop services**
   ```bash
   docker compose down
   ```

## API Endpoints

### Task Service (http://localhost:3001)

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/tasks` | Get all tasks |
| POST | `/api/tasks` | Create a new task |
| PUT | `/api/tasks/:id` | Update a task |
| DELETE | `/api/tasks/:id` | Delete a task |
| GET | `/health` | Health check |

### User Service (http://localhost:3002)

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/auth/register` | Register new user |
| POST | `/api/auth/login` | User login |
| GET | `/api/auth/profile` | Get user profile (requires token) |
| GET | `/health` | Health check |

## Database Schema

### Tasks Database (todo_tasks)
```sql
CREATE TABLE tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Users Database (todo_users)
```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

## Environment Variables

### Task Service
- `DB_HOST`: Database host (default: db)
- `DB_USER`: Database user (default: root)
- `DB_PASSWORD`: Database password (default: password)
- `DB_NAME`: Database name (default: todo_tasks)
- `DB_PORT`: Database port (default: 3306)
- `PORT`: Service port (default: 3001)

### User Service
- `DB_HOST`: Database host (default: db)
- `DB_USER`: Database user (default: root)
- `DB_PASSWORD`: Database password (default: password)
- `DB_NAME`: Database name (default: todo_users)
- `DB_PORT`: Database port (default: 3306)
- `PORT`: Service port (default: 3002)
- `JWT_SECRET`: JWT secret key (change in production)

## Development

### Running Individual Services

**Frontend (React):**
```bash
cd frontend
npm install
npm start
```

**Task Service (Node.js):**
```bash
cd backend/task-service
npm install
npm start
```

**User Service (Python):**
```bash
cd backend/user-service
pip install -r requirements.txt
python app.py
```

## Testing

### Automated Testing

Run the comprehensive test suite:

**On Linux/Mac:**
```bash
./run-tests.sh
```

**On Windows (PowerShell):**
```powershell
.\run-tests.ps1
```

The test script will:
- Start all services with Docker Compose
- Verify service health
- Test all API endpoints
- Create, read, update, and delete test data
- Report results

### Manual API Testing

You can test the APIs using curl or tools like Postman:

```bash
# Get all tasks
curl http://localhost:3001/api/tasks

# Create a task
curl -X POST http://localhost:3001/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Test task", "completed": false}'

# Register a user
curl -X POST http://localhost:3002/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "email": "test@example.com", "password": "password123"}'
```

## Production Considerations

1. **Security**:
   - Change default passwords
   - Use strong JWT secrets
   - Implement proper CORS policies
   - Add rate limiting

2. **Database**:
   - Use connection pooling
   - Implement database migrations
   - Add database backups

3. **Monitoring**:
   - Add logging
   - Implement health checks
   - Add metrics collection

4. **Scalability**:
   - Implement load balancing
   - Add caching layers
   - Consider service discovery

## Troubleshooting

### Common Issues

1. **Port conflicts**: Ensure ports 3000-3002, 3307-3308, 8080 are available
2. **Memory issues**: Ensure at least 4GB RAM is available
3. **Database connection**: Check that MySQL containers are healthy
4. **Build failures**: Clear Docker cache with `docker system prune`

### Logs

Check service logs:
```bash
docker compose logs [service-name]
```

View all logs:
```bash
docker compose logs
```

## License

This project is for educational purposes. Feel free to modify and use as needed.
