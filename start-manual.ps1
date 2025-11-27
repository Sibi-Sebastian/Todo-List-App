# Manual Startup Script for To-Do Application
Write-Host "🚀 Starting To-Do Application Manually" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Function to start a service in background
function Start-ServiceProcess {
    param (
        [string]$ServiceName,
        [string]$Command,
        [string]$WorkingDir
    )

    Write-Host "Starting $ServiceName..." -ForegroundColor Yellow
    try {
        $process = Start-Process powershell -ArgumentList "-Command `"cd '$WorkingDir'; $Command`"" -NoNewWindow -PassThru
        Write-Host "✅ $ServiceName started (PID: $($process.Id))" -ForegroundColor Green
    } catch {
        Write-Host "❌ Failed to start $ServiceName" -ForegroundColor Red
    }
}

# Check MySQL
Write-Host "Checking MySQL..." -ForegroundColor Yellow
if (Get-Service -Name "*mysql*" -ErrorAction SilentlyContinue) {
    Write-Host "✅ MySQL is running" -ForegroundColor Green
} else {
    Write-Host "❌ MySQL is not running. Please start MySQL Server 8.0" -ForegroundColor Red
}

# Start Task Service
$taskServicePath = "C:\Users\sibis\Desktop\Projects\Personal\todoListApp\backend\task-service"
Start-ServiceProcess -ServiceName "Task Service" -Command "npm start" -WorkingDir $taskServicePath

# Check for Python (User Service)
Write-Host "Checking Python..." -ForegroundColor Yellow
try {
    $pythonVersion = python --version 2>$null
    Write-Host "✅ Python found: $pythonVersion" -ForegroundColor Green

    # Start User Service
    $userServicePath = "C:\Users\sibis\Desktop\Projects\Personal\todoListApp\backend\user-service"
    Start-ServiceProcess -ServiceName "User Service" -Command "python app.py" -WorkingDir $userServicePath
} catch {
    Write-Host "⚠️  Python not found. User Service will not start." -ForegroundColor Yellow
    Write-Host "   Install Python from: https://python.org" -ForegroundColor White
}

# Start Frontend
$frontendPath = "C:\Users\sibis\Desktop\Projects\Personal\todoListApp\frontend"
Start-ServiceProcess -ServiceName "Frontend" -Command "npm start" -WorkingDir $frontendPath

Write-Host ""
Write-Host "🎉 Services starting up!" -ForegroundColor Green
Write-Host "=====================" -ForegroundColor Green
Write-Host "Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "Task API: http://localhost:3001" -ForegroundColor White
Write-Host "User API: http://localhost:3002 (if Python installed)" -ForegroundColor White
Write-Host ""
Write-Host "Wait 10-15 seconds for all services to start, then open http://localhost:3000" -ForegroundColor Cyan
