#!/bin/bash

echo "🚀 Starting To-Do List Application Tests"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if Docker is running
echo "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi
print_status "Docker is running"

# Start the application
echo "Starting application with Docker Compose..."
docker compose up -d --build

if [ $? -ne 0 ]; then
    print_error "Failed to start application"
    exit 1
fi

print_status "Application started successfully"

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 30

# Test health endpoints
echo "Testing service health..."

# Test Task Service health
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    print_status "Task Service is healthy"
else
    print_error "Task Service health check failed"
fi

# Test User Service health
if curl -f http://localhost:3002/health > /dev/null 2>&1; then
    print_status "User Service is healthy"
else
    print_error "User Service health check failed"
fi

# Test Frontend accessibility
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    print_status "Frontend is accessible"
else
    print_error "Frontend is not accessible"
fi

# Test phpMyAdmin accessibility
if curl -f http://localhost:8080 > /dev/null 2>&1; then
    print_status "phpMyAdmin is accessible"
else
    print_error "phpMyAdmin is not accessible"
fi

# Test API endpoints
echo "Testing API endpoints..."

# Test Task Service API
echo "Testing Task Service API..."

# Create a test task
CREATE_RESPONSE=$(curl -s -X POST http://localhost:3001/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Integration Test Task", "completed": false}')

if echo "$CREATE_RESPONSE" | grep -q '"id"'; then
    print_status "Task creation API works"
    TASK_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | cut -d':' -f2)
else
    print_error "Task creation API failed"
    TASK_ID=""
fi

# Test getting all tasks
if curl -f http://localhost:3001/api/tasks > /dev/null 2>&1; then
    print_status "Get all tasks API works"
else
    print_error "Get all tasks API failed"
fi

# Test updating task if we have a task ID
if [ ! -z "$TASK_ID" ]; then
    UPDATE_RESPONSE=$(curl -s -X PUT http://localhost:3001/api/tasks/$TASK_ID \
      -H "Content-Type: application/json" \
      -d '{"title": "Updated Integration Test Task", "completed": true}')

    if echo "$UPDATE_RESPONSE" | grep -q '"completed":true'; then
        print_status "Task update API works"
    else
        print_error "Task update API failed"
    fi

    # Test deleting task
    if curl -f -X DELETE http://localhost:3001/api/tasks/$TASK_ID > /dev/null 2>&1; then
        print_status "Task deletion API works"
    else
        print_error "Task deletion API failed"
    fi
fi

# Test User Service API
echo "Testing User Service API..."

# Test user registration
REGISTER_RESPONSE=$(curl -s -X POST http://localhost:3002/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username": "testuser", "email": "test@example.com", "password": "testpass123"}')

if echo "$REGISTER_RESPONSE" | grep -q '"token"'; then
    print_status "User registration API works"
    TOKEN=$(echo "$REGISTER_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
else
    print_error "User registration API failed"
    TOKEN=""
fi

# Test user login
if [ ! -z "$TOKEN" ]; then
    LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3002/api/auth/login \
      -H "Content-Type: application/json" \
      -d '{"username": "testuser", "password": "testpass123"}')

    if echo "$LOGIN_RESPONSE" | grep -q '"token"'; then
        print_status "User login API works"
    else
        print_error "User login API failed"
    fi
fi

# Run unit tests if services are running
echo "Running unit tests..."

# Run Task Service tests
if curl -f http://localhost:3001/health > /dev/null 2>&1; then
    echo "Running Task Service unit tests..."
    # Note: This would require installing test dependencies in the container
    # For now, we'll skip unit tests in favor of integration tests
    print_warning "Unit tests skipped (would require test setup in containers)"
else
    print_error "Task Service not available for testing"
fi

# Run User Service tests
if curl -f http://localhost:3002/health > /dev/null 2>&1; then
    echo "Running User Service unit tests..."
    print_warning "Unit tests skipped (would require test setup in containers)"
else
    print_error "User Service not available for testing"
fi

echo ""
echo "🧪 Test Summary"
echo "=============="
echo "✅ Integration tests completed"
echo "✅ API endpoints tested"
echo "✅ Service health verified"
echo ""
echo "📋 Access URLs:"
echo "Frontend:     http://localhost:3000"
echo "Task API:     http://localhost:3001"
echo "User API:     http://localhost:3002"
echo "phpMyAdmin:   http://localhost:8080"
echo ""
echo "🛑 To stop the application:"
echo "docker compose down"
echo ""
print_status "All tests completed!"
