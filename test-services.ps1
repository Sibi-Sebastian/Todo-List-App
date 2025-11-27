# Simple test script for To-Do List Application
Write-Host "🧪 Testing To-Do List Application Services" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Test URLs
$urls = @(
    @{url = "http://localhost:3000"; name = "Frontend"},
    @{url = "http://localhost:3001/health"; name = "Task Service"},
    @{url = "http://localhost:3002/health"; name = "User Service"},
    @{url = "http://localhost:8080"; name = "phpMyAdmin"}
)

Write-Host "Testing service availability..." -ForegroundColor Yellow

foreach ($service in $urls) {
    try {
        $response = Invoke-WebRequest -Uri $service.url -TimeoutSec 5 -ErrorAction Stop
        Write-Host "✅ $($service.name): Available (Status: $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "❌ $($service.name): Not available - $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host "`nTesting API endpoints..." -ForegroundColor Yellow

# Test Task Service API
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3001/api/tasks" -TimeoutSec 5
    Write-Host "✅ Task API: Working" -ForegroundColor Green
} catch {
    Write-Host "❌ Task API: Failed - $($_.Exception.Message)" -ForegroundColor Red
}

# Test User Service API
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3002/health" -TimeoutSec 5
    Write-Host "✅ User API: Working" -ForegroundColor Green
} catch {
    Write-Host "❌ User API: Failed - $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n📋 Summary:" -ForegroundColor Cyan
Write-Host "- Frontend should be running on http://localhost:3000" -ForegroundColor White
Write-Host "- If services are not working, Docker containers may not be running" -ForegroundColor White
Write-Host "- Try: docker compose up -d" -ForegroundColor White
