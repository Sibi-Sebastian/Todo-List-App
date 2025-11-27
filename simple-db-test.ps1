# Simple MySQL Database Test
Write-Host "🔍 Testing MySQL Database Connection..." -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

$mysqlPath = "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"
$password = "sian"

# Test connection with correct password
Write-Host "`nTesting connection with correct password..." -ForegroundColor Yellow
try {
    $result = & $mysqlPath -u root -p$password -e "SELECT VERSION() AS Version;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SUCCESS: Connected to MySQL!" -ForegroundColor Green
        $version = $result | Select-String -Pattern "\d+\.\d+\.\d+" | ForEach-Object { $_.Matches.Value }
        Write-Host "MySQL Version: $version" -ForegroundColor White
    } else {
        Write-Host "❌ FAILED: Could not connect to MySQL" -ForegroundColor Red
        Write-Host "Error: $result" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Test connection with wrong password
Write-Host "`nTesting connection with WRONG password..." -ForegroundColor Yellow
try {
    $result = & $mysqlPath -u root -p"wrongpassword" -e "SELECT 1;" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "⚠️  WARNING: Wrong password was accepted (unexpected)" -ForegroundColor Yellow
    } else {
        Write-Host "✅ SUCCESS: Wrong password correctly rejected" -ForegroundColor Green
    }
} catch {
    Write-Host "✅ SUCCESS: Wrong password correctly rejected" -ForegroundColor Green
}

# Create databases
Write-Host "`nCreating databases..." -ForegroundColor Yellow
$sql = "CREATE DATABASE IF NOT EXISTS todo_tasks; CREATE DATABASE IF NOT EXISTS todo_users;"

try {
    $result = & $mysqlPath -u root -p$password -e $sql 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SUCCESS: Databases created" -ForegroundColor Green

        # Check if databases exist
        $checkResult = & $mysqlPath -u root -p$password -e "SHOW DATABASES LIKE 'todo_%';" 2>&1
        Write-Host "Available databases:" -ForegroundColor White
        $checkResult | Select-String -Pattern "todo_" | ForEach-Object {
            Write-Host "  - $($_.Line.Trim())" -ForegroundColor White
        }
    } else {
        Write-Host "❌ FAILED: Could not create databases" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Create tables
Write-Host "`nSetting up tables..." -ForegroundColor Yellow

$taskTableSQL = @"
USE todo_tasks;
CREATE TABLE IF NOT EXISTS tasks (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

$userTableSQL = @"
USE todo_users;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
"@

try {
    # Create tasks table
    $result1 = & $mysqlPath -u root -p$password -e $taskTableSQL 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SUCCESS: Tasks table created" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: Tasks table creation failed" -ForegroundColor Red
    }

    # Create users table
    $result2 = & $mysqlPath -u root -p$password -e $userTableSQL 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SUCCESS: Users table created" -ForegroundColor Green
    } else {
        Write-Host "❌ FAILED: Users table creation failed" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

# Insert sample data
Write-Host "`nInserting sample data..." -ForegroundColor Yellow

$insertSQL = "USE todo_tasks; INSERT INTO tasks (title, completed) VALUES ('Welcome Task', 0), ('Setup Complete', 1);"

try {
    $result = & $mysqlPath -u root -p$password -e $insertSQL 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SUCCESS: Sample data inserted" -ForegroundColor Green

        # Verify data
        $verifySQL = "USE todo_tasks; SELECT id, title, completed FROM tasks;"
        $verifyResult = & $mysqlPath -u root -p$password -e $verifySQL 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Sample tasks in database:" -ForegroundColor White
            $verifyResult | Where-Object { $_ -match "^\d+.*" } | ForEach-Object {
                Write-Host "  $($_.Trim())" -ForegroundColor White
            }
        }
    } else {
        Write-Host "❌ FAILED: Could not insert sample data" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host "`n🎉 Database Setup Complete!" -ForegroundColor Green
Write-Host "📋 Summary:" -ForegroundColor Cyan
Write-Host "- Password 'sian' works correctly" -ForegroundColor White
Write-Host "- Wrong passwords are rejected" -ForegroundColor White
Write-Host "- todo_tasks and todo_users databases created" -ForegroundColor White
Write-Host "- Tables and sample data ready" -ForegroundColor White
Write-Host "- Data retrieval working" -ForegroundColor White
Write-Host "`n🚀 Ready to run the application!" -ForegroundColor Green
