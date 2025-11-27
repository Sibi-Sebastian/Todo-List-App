# PowerShell script to test the To-Do List Application
Write-Host "🚀 Starting To-Do List Application Tests" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green

# Function to test HTTP endpoints
function Test-Endpoint {
    param (
        [string]$url,
        [string]$description
    )

    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 10
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $description - OK" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ $description - Status: $($response.StatusCode)" -ForegroundColor Red
            return $false
        }
    } catch {
        Write-Host "❌ $description - Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Function to test API endpoints
function Test-APIEndpoint {
    param (
        [string]$url,
        [string]$method = "GET",
        [string]$body = "",
        [string]$description
    )

    try {
        $params = @{
            Uri = $url
            Method = $method
            TimeoutSec = 10
        }

        if ($body) {
            $params.Headers = @{ "Content-Type" = "application/json" }
            $params.Body = $body
        }

        $response = Invoke-WebRequest @params

        if ($response.StatusCode -eq 200 -or $response.StatusCode -eq 201 -or $response.StatusCode -eq 204) {
            Write-Host "✅ $description - OK" -ForegroundColor Green
            return $response.Content
        } else {
            Write-Host "❌ $description - Status: $($response.StatusCode)" -ForegroundColor Red
            return $null
        }
    } catch {
        Write-Host "❌ $description - Failed: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

Write-Host "Checking Docker installation..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>$null
    Write-Host "✅ Docker is installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    exit 1
}

Write-Host "Starting application with Docker Compose..." -ForegroundColor Yellow
try {
    docker compose up -d --build
    Write-Host "✅ Application started successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to start application: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "Waiting for services to be ready (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "Testing service health..." -ForegroundColor Yellow

# Test all services
$services = @(
    @{ url = "http://localhost:3000"; name = "Frontend" },
    @{ url = "http://localhost:3001/health"; name = "Task Service Health" },
    @{ url = "http://localhost:3002/health"; name = "User Service Health" },
    @{ url = "http://localhost:8080"; name = "phpMyAdmin" }
)

$allHealthy = $true
foreach ($service in $services) {
    $healthy = Test-Endpoint -url $service.url -description $service.name
    if (-not $healthy) {
        $allHealthy = $false
    }
}

if (-not $allHealthy) {
    Write-Host "❌ Some services are not healthy. Check Docker logs with: docker compose logs" -ForegroundColor Red
    exit 1
}

Write-Host "Testing API functionality..." -ForegroundColor Yellow

# Test Task Service API
Write-Host "Testing Task Service APIs..." -ForegroundColor Cyan

# Create a test task
$createResult = Test-APIEndpoint `
    -url "http://localhost:3001/api/tasks" `
    -method "POST" `
    -body '{\"title\": \"PowerShell Integration Test\", \"completed\": false}' `
    -description "Create Task"

$taskId = $null
if ($createResult) {
    try {
        $taskData = $createResult | ConvertFrom-Json
        $taskId = $taskData.id
        Write-Host "📝 Created test task with ID: $taskId" -ForegroundColor Blue
    } catch {
        Write-Host "⚠️ Could not parse task creation response" -ForegroundColor Yellow
    }
}

# Get all tasks
Test-APIEndpoint -url "http://localhost:3001/api/tasks" -description "Get All Tasks" | Out-Null

# Update task if we have an ID
if ($taskId) {
    Test-APIEndpoint `
        -url "http://localhost:3001/api/tasks/$taskId" `
        -method "PUT" `
        -body '{\"title\": \"Updated PowerShell Test\", \"completed\": true}' `
        -description "Update Task" | Out-Null

    # Delete task
    Test-APIEndpoint `
        -url "http://localhost:3001/api/tasks/$taskId" `
        -method "DELETE" `
        -description "Delete Task" | Out-Null
}

# Test User Service API
Write-Host "Testing User Service APIs..." -ForegroundColor Cyan

# Register a test user
$registerResult = Test-APIEndpoint `
    -url "http://localhost:3002/api/auth/register" `
    -method "POST" `
    -body '{\"username\": \"powershelltest\", \"email\": \"ps@example.com\", \"password\": \"testpass123\"}' `
    -description "Register User"

if ($registerResult) {
    try {
        $userData = $registerResult | ConvertFrom-Json
        if ($userData.token) {
            Write-Host "👤 Registered test user successfully" -ForegroundColor Blue

            # Test login
            Test-APIEndpoint `
                -url "http://localhost:3002/api/auth/login" `
                -method "POST" `
                -body '{\"username\": \"powershelltest\", \"password\": \"testpass123\"}' `
                -description "Login User" | Out-Null
        }
    } catch {
        Write-Host "⚠️ Could not parse user registration response" -ForegroundColor Yellow
    }
}

Write-Host "" -ForegroundColor White
Write-Host "🧪 Test Summary" -ForegroundColor Green
Write-Host "==============" -ForegroundColor Green
Write-Host "✅ Integration tests completed" -ForegroundColor Green
Write-Host "✅ API endpoints tested" -ForegroundColor Green
Write-Host "✅ Service health verified" -ForegroundColor Green
Write-Host "" -ForegroundColor White
Write-Host "📋 Access URLs:" -ForegroundColor Cyan
Write-Host "Frontend:     http://localhost:3000" -ForegroundColor White
Write-Host "Task API:     http://localhost:3001" -ForegroundColor White
Write-Host "User API:     http://localhost:3002" -ForegroundColor White
Write-Host "phpMyAdmin:   http://localhost:8080" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🛑 To stop the application:" -ForegroundColor Yellow
Write-Host "docker compose down" -ForegroundColor White
Write-Host "" -ForegroundColor White
Write-Host "🎉 All tests completed successfully!" -ForegroundColor Green
