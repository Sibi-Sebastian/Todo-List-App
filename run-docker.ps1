# Docker Startup Script for To-Do Application
Write-Host "🚀 Starting To-Do Application with Docker" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    docker ps > $null 2>&1
    Write-Host "✅ Docker is running" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running. Please start Docker Desktop first." -ForegroundColor Red
    Write-Host "   1. Open Docker Desktop" -ForegroundColor White
    Write-Host "   2. Wait for Docker to fully start" -ForegroundColor White
    Write-Host "   3. Run this script again" -ForegroundColor White
    exit 1
}

# Stop any existing containers
Write-Host "Stopping any existing containers..." -ForegroundColor Yellow
docker-compose down > $null 2>&1

# Build and start all services
Write-Host "Building and starting services..." -ForegroundColor Yellow
Write-Host "This may take a few minutes on first run..." -ForegroundColor Cyan
docker-compose up --build -d

# Wait for services to be ready
Write-Host "Waiting for services to start (60 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 60

# Check service status
Write-Host ""
Write-Host "🔍 Checking service status:" -ForegroundColor Cyan

# Check Task Service
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 10
    Write-Host "✅ Task Service: Running on port 3001" -ForegroundColor Green
} catch {
    Write-Host "❌ Task Service: Not responding" -ForegroundColor Red
}

# Check User Service
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3002/health" -TimeoutSec 10
    Write-Host "✅ User Service: Running on port 3002" -ForegroundColor Green
} catch {
    Write-Host "❌ User Service: Not responding" -ForegroundColor Red
}

# Check Frontend
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 10
    Write-Host "✅ Frontend: Running on port 3000" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend: Not responding" -ForegroundColor Red
}

# Check phpMyAdmin
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080" -TimeoutSec 10
    Write-Host "✅ phpMyAdmin: Running on port 8080" -ForegroundColor Green
} catch {
    Write-Host "❌ phpMyAdmin: Not responding" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Docker services started!" -ForegroundColor Green
Write-Host "==========================" -ForegroundColor Green
Write-Host "Frontend:    http://localhost:3000" -ForegroundColor White
Write-Host "Task API:    http://localhost:3001" -ForegroundColor White
Write-Host "User API:    http://localhost:3002" -ForegroundColor White
Write-Host "phpMyAdmin:  http://localhost:8080" -ForegroundColor White
Write-Host ""
Write-Host "📋 Useful Docker commands:" -ForegroundColor Yellow
Write-Host "Stop services:  docker-compose down" -ForegroundColor White
Write-Host "View logs:      docker-compose logs -f [service-name]" -ForegroundColor White
Write-Host "Restart service: docker-compose restart [service-name]" -ForegroundColor White
Write-Host "Rebuild:        docker-compose up --build -d" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Service names: frontend, task-service, user-service, tasks-db, users-db, phpmyadmin" -ForegroundColor Cyan
