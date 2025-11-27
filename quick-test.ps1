# Quick test for To-Do Application
Write-Host "Testing To-Do Application..." -ForegroundColor Green

# Test Frontend
try {
    Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5 | Out-Null
    Write-Host "✅ Frontend: Running" -ForegroundColor Green
} catch {
    Write-Host "❌ Frontend: Not running" -ForegroundColor Red
}

# Test Task Service
try {
    Invoke-WebRequest -Uri "http://localhost:3001/health" -TimeoutSec 5 | Out-Null
    Write-Host "✅ Task Service: Running" -ForegroundColor Green
} catch {
    Write-Host "❌ Task Service: Not running" -ForegroundColor Red
}

# Test User Service
try {
    Invoke-WebRequest -Uri "http://localhost:3002/health" -TimeoutSec 5 | Out-Null
    Write-Host "✅ User Service: Running" -ForegroundColor Green
} catch {
    Write-Host "❌ User Service: Not running" -ForegroundColor Red
}

Write-Host "`nIf services are not running, start Docker with:" -ForegroundColor Yellow
Write-Host "docker compose up -d" -ForegroundColor White
