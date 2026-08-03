# ============================================================================
# Full Stack Application - Diagnostic and Setup Script (PowerShell)
# ============================================================================
# This script diagnoses and fixes "Network Error" on Register page
# ============================================================================

Write-Host "`n"
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FULL STACK APPLICATION - DIAGNOSTIC REPORT" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
Write-Host "`n"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Initialize test results
$testsPassed = 0
$testsFailed = 0

# ===========================================================================
# Helper function to display test results
# ===========================================================================
function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$TestBlock,
        [string]$FailureMessage = "Test failed"
    )
    
    Write-Host "[TEST] $Name" -ForegroundColor Cyan
    try {
        $result = & $TestBlock
        if ($result) {
            Write-Host "✓ PASSED" -ForegroundColor Green
            $script:testsPassed++
        } else {
            Write-Host "❌ FAILED: $FailureMessage" -ForegroundColor Red
            $script:testsFailed++
        }
    } catch {
        Write-Host "❌ FAILED: $($_.Exception.Message)" -ForegroundColor Red
        $script:testsFailed++
    }
    Write-Host "`n"
}

# ===========================================================================
# TEST 1: Java Installation
# ===========================================================================
Test-Component -Name "Java Installation" -TestBlock {
    try {
        $output = & java -version 2>&1
        Write-Host $output
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

# ===========================================================================
# TEST 2: Maven Installation
# ===========================================================================
Test-Component -Name "Maven Installation" -TestBlock {
    try {
        $mvnPath = (Get-Command mvn -ErrorAction SilentlyContinue).Source
        if ($mvnPath) {
            Write-Host "Found Maven at: $mvnPath"
            & mvn -version
            return $true
        } elseif (Test-Path "backend\mvnw.cmd") {
            Write-Host "Maven wrapper found at: backend\mvnw.cmd"
            return $true
        } else {
            Write-Host "Maven not found in PATH or as wrapper"
            return $false
        }
    } catch {
        return $false
    }
}

# ===========================================================================
# TEST 3: Node.js Installation
# ===========================================================================
Test-Component -Name "Node.js Installation" -TestBlock {
    try {
        $version = & node --version
        $npmVersion = & npm --version
        Write-Host "Node: $version"
        Write-Host "NPM: $npmVersion"
        return $true
    } catch {
        Write-Host "Node.js not installed"
        return $false
    }
}

# ===========================================================================
# TEST 4: Frontend .env File
# ===========================================================================
Write-Host "[TEST 4] Frontend .env Configuration" -ForegroundColor Cyan
if (-not (Test-Path "frontend\.env")) {
    Write-Host "Creating frontend\.env..."
    @"
REACT_APP_API_URL=http://localhost:8080/api
"@ | Out-File -FilePath "frontend\.env" -Encoding UTF8
    Write-Host "✓ PASSED: Created frontend\.env" -ForegroundColor Green
    $script:testsPassed++
} else {
    Write-Host "✓ PASSED: frontend\.env exists" -ForegroundColor Green
    Write-Host "Contents:"
    Get-Content "frontend\.env"
    $script:testsPassed++
}
Write-Host "`n"

# ===========================================================================
# TEST 5: Frontend node_modules
# ===========================================================================
if (Test-Path "frontend\node_modules") {
    Write-Host "[TEST 5] Frontend Dependencies" -ForegroundColor Cyan
    Write-Host "✓ PASSED: node_modules directory exists" -ForegroundColor Green
    $script:testsPassed++
} else {
    Write-Host "[TEST 5] Frontend Dependencies" -ForegroundColor Cyan
    Write-Host "⚠ WARNING: node_modules not installed" -ForegroundColor Yellow
    Write-Host "Run: cd frontend && npm install" -ForegroundColor Yellow
}
Write-Host "`n"

# ===========================================================================
# TEST 6: Backend Configuration
# ===========================================================================
Write-Host "[TEST 6] Backend Configuration" -ForegroundColor Cyan
if (Test-Path "backend\src\main\resources\application.properties") {
    Write-Host "✓ PASSED: application.properties exists" -ForegroundColor Green
    Write-Host "`nDatabase Configuration:" -ForegroundColor Yellow
    Select-String -Path "backend\src\main\resources\application.properties" -Pattern "^spring.datasource|^spring.jpa" | ForEach-Object { Write-Host $_.Line }
    Write-Host "`nJWT Configuration:" -ForegroundColor Yellow
    Select-String -Path "backend\src\main\resources\application.properties" -Pattern "^jwt" | ForEach-Object { Write-Host $_.Line }
    $script:testsPassed++
} else {
    Write-Host "❌ FAILED: application.properties not found" -ForegroundColor Red
    $script:testsFailed++
}
Write-Host "`n"

# ===========================================================================
# TEST 7: API Connectivity
# ===========================================================================
Write-Host "[TEST 7] API Connectivity (Backend must be running)" -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
    Write-Host "✓ PASSED: Backend is responding with HTTP $($response.StatusCode)" -ForegroundColor Green
    $script:testsPassed++
} catch {
    Write-Host "⚠ WARNING: Backend is not responding" -ForegroundColor Yellow
    Write-Host "This is expected if the backend is not running yet." -ForegroundColor Yellow
    Write-Host "Start backend with: START_BACKEND.bat" -ForegroundColor Yellow
}
Write-Host "`n"

# ===========================================================================
# TEST 8: Project Structure
# ===========================================================================
Write-Host "[TEST 8] Project Structure" -ForegroundColor Cyan
$structureOk = $true
$files = @(
    "backend\pom.xml",
    "backend\src\main\java\com\example\backend\BackendApplication.java",
    "frontend\package.json",
    "frontend\src\App.js"
)
foreach ($file in $files) {
    if (Test-Path $file) {
        Write-Host "✓ Found: $file" -ForegroundColor Green
        $script:testsPassed++
    } else {
        Write-Host "❌ Missing: $file" -ForegroundColor Red
        $structureOk = $false
        $script:testsFailed++
    }
}
Write-Host "`n"

# ===========================================================================
# TEST 9: API Service Files
# ===========================================================================
Write-Host "[TEST 9] Frontend API Configuration" -ForegroundColor Cyan
$apiFiles = @{
    "api.js" = "frontend\src\services\api.js"
    "authService.js" = "frontend\src\services\authService.js"
}
foreach ($name in $apiFiles.Keys) {
    if (Test-Path $apiFiles[$name]) {
        Write-Host "✓ Found: $name" -ForegroundColor Green
        if ($name -eq "api.js") {
            Write-Host "  Configured baseURL:"
            Select-String -Path $apiFiles[$name] -Pattern "baseURL" | Select-Object -First 1 | ForEach-Object { Write-Host "  $_" }
        }
        $script:testsPassed++
    } else {
        Write-Host "❌ Missing: $name" -ForegroundColor Red
        $script:testsFailed++
    }
}
Write-Host "`n"

# ===========================================================================
# Display Summary
# ===========================================================================
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "DIAGNOSTIC SUMMARY" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "Tests Passed: $testsPassed" -ForegroundColor Green
Write-Host "Tests Failed: $testsFailed" -ForegroundColor $(if ($testsFailed -eq 0) { 'Green' } else { 'Red' })
Write-Host "`n"

# ===========================================================================
# Display Setup Instructions
# ===========================================================================
Write-Host "SETUP INSTRUCTIONS" -ForegroundColor Yellow
Write-Host "================================================================" -ForegroundColor Yellow
Write-Host "`n"
Write-Host "Step 1: Start the Backend" -ForegroundColor Cyan
Write-Host "  Option A: Run the batch file"
Write-Host "    > START_BACKEND.bat"
Write-Host "  Option B: Run Maven manually"
Write-Host "    > cd backend"
Write-Host "    > mvn spring-boot:run"
Write-Host "`n"

Write-Host "Step 2: In a NEW terminal, start the Frontend" -ForegroundColor Cyan
Write-Host "  Option A: Run the batch file"
Write-Host "    > START_FRONTEND.bat"
Write-Host "  Option B: Run npm manually"
Write-Host "    > cd frontend"
Write-Host "    > npm install  (if first time)"
Write-Host "    > npm start"
Write-Host "`n"

Write-Host "Step 3: Test the Application" -ForegroundColor Cyan
Write-Host "  1. Open: http://localhost:3000"
Write-Host "  2. Click 'Register'"
Write-Host "  3. Fill in the form:"
Write-Host "     - Full Name: Test User"
Write-Host "     - Email: test@example.com"
Write-Host "     - Username: testuser"
Write-Host "     - Password: TestPass123"
Write-Host "  4. Click Register"
Write-Host "`n"

Write-Host "Step 4: Verify Backend is Running" -ForegroundColor Cyan
Write-Host "  Check that you see this in the backend terminal:"
Write-Host "    'Started BackendApplication in ... seconds'"
Write-Host "    'Tomcat started on port(s): 8080'"
Write-Host "`n"

Write-Host "Step 5: Troubleshooting" -ForegroundColor Cyan
Write-Host "  If you still see 'Network Error':"
Write-Host "    1. Check backend terminal for errors"
Write-Host "    2. Open browser DevTools (F12)"
Write-Host "    3. Go to Console tab - look for error messages"
Write-Host "    4. Go to Network tab - check the Register request"
Write-Host "    5. Check if backend responds: curl http://localhost:8080/api/users"
Write-Host "`n"

Write-Host "================================================================" -ForegroundColor Yellow
Write-Host "`n"

if ($testsFailed -gt 0) {
    Write-Host "⚠ Some tests failed. Please review above for details." -ForegroundColor Yellow
    Write-Host "Most common issue: Backend not running" -ForegroundColor Yellow
    Write-Host "`nRun START_BACKEND.bat to start the backend!" -ForegroundColor Cyan
}

Write-Host "`nPress any key to close..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
