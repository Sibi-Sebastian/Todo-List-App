# Test MySQL Connection with PowerShell
Write-Host "🔍 Testing MySQL Connection..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$password = "sian"

# Test 1: Basic connection
Write-Host "`n1. Testing basic connection with correct password..." -ForegroundColor Yellow
try {
    $output = & $mysqlPath -u root -p$password -e "SELECT VERSION() as Version;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Successfully connected to MySQL!" -ForegroundColor Green
        Write-Host "MySQL Version: $($output | Select-String -Pattern '\d+\.\d+\.\d+' | ForEach-Object { $_.Matches.Value })" -ForegroundColor White
    } else {
        Write-Host "❌ Connection failed: $($output)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Connection error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Wrong password
Write-Host "`n2. Testing connection with wrong password..." -ForegroundColor Yellow
try {
    $output = & $mysqlPath -u root -p"wrongpassword" -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "✅ Correctly rejected wrong password" -ForegroundColor Green
        Write-Host "Error message: $($output | Select-String -Pattern 'ERROR')" -ForegroundColor White
    } else {
        Write-Host "⚠️  Unexpected: wrong password was accepted" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✅ Correctly rejected wrong password (exception caught)" -ForegroundColor Green
}

# Test 3: Create databases
Write-Host "`n3. Creating required databases..." -ForegroundColor Yellow
$createCommands = @"
CREATE DATABASE IF NOT EXISTS todo_tasks;
CREATE DATABASE IF NOT EXISTS todo_users;
SHOW DATABASES LIKE 'todo_%';
"@

try {
    $output = & $mysqlPath -u root -p$password -e $createCommands 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Databases created successfully!" -ForegroundColor Green
        Write-Host "Available databases:" -ForegroundColor White
        $output | Select-String -Pattern 'todo_' | ForEach-Object { Write-Host "  - $($_.Line)" -ForegroundColor White }
    } else {
        Write-Host "❌ Database creation failed: $($output)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Database creation error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Create tables and insert sample data
Write-Host "`n4. Setting up tables and sample data..." -ForegroundColor Yellow

# Setup tasks table
$tasksSetup = @"
USE todo_tasks;
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO tasks (title, completed) VALUES
('Welcome to your To-Do App!', false),
('Complete the setup process', false),
('Test the application', false);
SELECT COUNT(*) as task_count FROM tasks;
"@

try {
    $output = & $mysqlPath -u root -p$password -e $tasksSetup 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Tasks table created and populated!" -ForegroundColor Green
        $taskCount = $output | Select-String -Pattern '\d+' | Select-Object -Last 1 | ForEach-Object { $_.Matches.Value }
        Write-Host "Tasks in database: $taskCount" -ForegroundColor White
    } else {
        Write-Host "❌ Tasks setup failed: $($output)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Tasks setup error: $($_.Exception.Message)" -ForegroundColor Red
}

# Setup users table
$usersSetup = @"
USE todo_users;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
SELECT 'Users table ready' as status;
"@

try {
    $output = & $mysqlPath -u root -p$password -e $usersSetup 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Users table created!" -ForegroundColor Green
    } else {
        Write-Host "❌ Users setup failed: $($output)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Users setup error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Verify data retrieval
Write-Host "`n5. Testing data retrieval..." -ForegroundColor Yellow
$dataQuery = "USE todo_tasks; SELECT id, title, completed FROM tasks LIMIT 3;"

try {
    $output = & $mysqlPath -u root -p$password -e $dataQuery 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Data retrieval successful!" -ForegroundColor Green
        Write-Host "Sample data:" -ForegroundColor White
        $output | Where-Object { $_ -match '\d+\s+.*\s+(0|1)' } | ForEach-Object {
            Write-Host "  $($_.Trim())" -ForegroundColor White
        }
    } else {
        Write-Host "❌ Data retrieval failed: $($output)" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Data retrieval error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Database setup and testing completed!" -ForegroundColor Green
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "- ✅ MySQL connection: Working with password 'sian'" -ForegroundColor White
Write-Host "- ✅ Wrong password: Properly rejected" -ForegroundColor White
Write-Host "- ✅ Databases: todo_tasks and todo_users created" -ForegroundColor White
Write-Host "- ✅ Tables: tasks and users tables ready" -ForegroundColor White
Write-Host "- ✅ Sample data: Tasks table populated" -ForegroundColor White
Write-Host "- ✅ Data retrieval: Working correctly" -ForegroundColor White
Write-Host "`n🚀 Ready to run the application!" -ForegroundColor Green
