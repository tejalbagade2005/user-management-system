# ============================================================================
# FULL STACK VERIFICATION SCRIPT
# ============================================================================
# This script comprehensively verifies that your full stack is working
# correctly. It tests all components and provides detailed reporting.
#
# Usage: .\VERIFY.ps1
# ============================================================================

Write-Host "`n"
Write-Host "╔════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         FULL STACK VERIFICATION & TESTING SCRIPT                       ║" -ForegroundColor Cyan
Write-Host "║              Testing Frontend, Backend, and Database                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host "`nGenerated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptDir

# Color scheme
$success = "Green"
$warning = "Yellow"
$error = "Red"
$info = "Cyan"

# Test counters
$totalTests = 0
$passedTests = 0
$failedTests = 0
$warnings = 0

# ============================================================================
# Helper Functions
# ============================================================================

function Report-Test {
    param(
        [string]$Name,
        [string]$Status,  # "PASS", "FAIL", "WARN"
        [string]$Message = "",
        [string]$Details = ""
    )
    
    $totalTests++
    $statusColor = switch($Status) {
        "PASS" { $success; $passedTests++ }
        "FAIL" { $error; $failedTests++ }
        "WARN" { $warning; $warnings++ }
    }
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] " -NoNewline -ForegroundColor Gray
    Write-Host "$Status".PadRight(6) -ForegroundColor $statusColor -NoNewline
    Write-Host " | " -NoNewline -ForegroundColor Gray
    Write-Host "$Name" -NoNewline
    
    if ($Message) {
        Write-Host " → $Message"
    } else {
        Write-Host ""
    }
    
    if ($Details) {
        Write-Host "         $Details" -ForegroundColor Gray
    }
}

function Test-Section {
    param(
        [string]$Title
    )
    Write-Host "`n┌─ $Title" -ForegroundColor $info
    Write-Host "└─────────────────────────────────────────────────────────────────────" -ForegroundColor $info
}

# ============================================================================
# SECTION 1: ENVIRONMENT VERIFICATION
# ============================================================================

Test-Section "1. ENVIRONMENT VERIFICATION"

# Test Java
try {
    $javaVersion = & java -version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $version = $javaVersion[0] -match '(\d+\.\d+|version "?\d+)' | Out-Null
        Report-Test "Java Installation" "PASS" "Found Java"
    } else {
        Report-Test "Java Installation" "FAIL" "Java not found or error"
    }
} catch {
    Report-Test "Java Installation" "FAIL" "Exception: $($_.Exception.Message)"
}

# Test Maven
$mvnAvailable = $false
try {
    $mvnPath = (Get-Command mvn -ErrorAction SilentlyContinue).Source
    if ($mvnPath) {
        Report-Test "Maven (PATH)" "PASS" "Found at: $mvnPath"
        $mvnAvailable = $true
    }
} catch { }

if (-not $mvnAvailable) {
    if (Test-Path "backend\mvnw.cmd") {
        Report-Test "Maven (Wrapper)" "PASS" "Using Maven wrapper"
        $mvnAvailable = $true
    } elseif (Test-Path "backend\mvnw") {
        Report-Test "Maven (Wrapper)" "PASS" "Using Maven wrapper"
        $mvnAvailable = $true
    } else {
        Report-Test "Maven" "FAIL" "Maven not found in PATH or as wrapper"
    }
}

# Test Node.js
try {
    $nodeVersion = & node --version
    if ($LASTEXITCODE -eq 0) {
        Report-Test "Node.js" "PASS" "Version: $nodeVersion"
    } else {
        Report-Test "Node.js" "FAIL" "Node.js error"
    }
} catch {
    Report-Test "Node.js" "FAIL" "Not installed"
}

# Test npm
try {
    $npmVersion = & npm --version
    if ($LASTEXITCODE -eq 0) {
        Report-Test "npm" "PASS" "Version: $npmVersion"
    } else {
        Report-Test "npm" "FAIL" "npm error"
    }
} catch {
    Report-Test "npm" "FAIL" "Not installed"
}

# ============================================================================
# SECTION 2: CONFIGURATION FILES
# ============================================================================

Test-Section "2. CONFIGURATION FILES"

# Check frontend .env
if (Test-Path "frontend\.env") {
    $envContent = Get-Content "frontend\.env" -ErrorAction SilentlyContinue
    if ($envContent -like "*REACT_APP_API_URL*") {
        Report-Test "frontend/.env" "PASS" "Configuration found"
    } else {
        Report-Test "frontend/.env" "WARN" "File exists but REACT_APP_API_URL not configured"
    }
} else {
    Report-Test "frontend/.env" "FAIL" "File not found"
}

# Check backend application.properties
if (Test-Path "backend\src\main\resources\application.properties") {
    $appProps = Get-Content "backend\src\main\resources\application.properties"
    $hasDB = $appProps | Select-String "spring.datasource.url"
    $hasH2 = $appProps | Select-String "spring.h2.console.enabled"
    
    if ($hasDB) {
        Report-Test "backend/application.properties" "PASS" "Database configured"
    } else {
        Report-Test "backend/application.properties" "FAIL" "No database configuration found"
    }
} else {
    Report-Test "backend/application.properties" "FAIL" "File not found"
}

# ============================================================================
# SECTION 3: PROJECT STRUCTURE
# ============================================================================

Test-Section "3. PROJECT STRUCTURE"

$requiredFiles = @(
    @{"Path"="backend\pom.xml"; "Name"="Backend Maven POM"},
    @{"Path"="backend\src\main\java\com\example\backend\BackendApplication.java"; "Name"="Backend Main Application"},
    @{"Path"="frontend\package.json"; "Name"="Frontend Package Config"},
    @{"Path"="frontend\src\App.js"; "Name"="Frontend App Component"},
    @{"Path"="frontend\src\services\api.js"; "Name"="Frontend API Service"},
    @{"Path"="frontend\src\services\authService.js"; "Name"="Frontend Auth Service"},
    @{"Path"="backend\src\main\java\com\example\backend\controller\AuthController.java"; "Name"="Backend Auth Controller"}
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file.Path) {
        Report-Test $file.Name "PASS"
    } else {
        Report-Test $file.Name "FAIL" "Not found at: $($file.Path)"
    }
}

# ============================================================================
# SECTION 4: DEPENDENCIES
# ============================================================================

Test-Section "4. DEPENDENCIES"

if (Test-Path "frontend\node_modules") {
    $moduleCount = (Get-ChildItem "frontend\node_modules" -Directory | Measure-Object).Count
    Report-Test "npm Packages" "PASS" "$moduleCount packages installed"
} else {
    Report-Test "npm Packages" "FAIL" "node_modules not found - run: npm install"
}

# ============================================================================
# SECTION 5: CONNECTIVITY TESTS
# ============================================================================

Test-Section "5. CONNECTIVITY TESTS"

Write-Host "(Testing API endpoints...)`n" -ForegroundColor Gray

# Test backend on port 8080
Write-Host "  Checking if Backend is running on http://localhost:8080..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Report-Test "Backend API (GET /users)" "PASS" "HTTP 200 - Backend is responding"
    } elseif ($response.StatusCode -eq 403 -or $response.StatusCode -eq 401) {
        Report-Test "Backend API (GET /users)" "PASS" "HTTP $($response.StatusCode) - Backend is running (auth required)"
    } else {
        Report-Test "Backend API (GET /users)" "WARN" "HTTP $($response.StatusCode)"
    }
} catch {
    $errMsg = $_.Exception.Message
    if ($errMsg -like "*Connection refused*" -or $errMsg -like "*No connection*") {
        Report-Test "Backend API (GET /users)" "FAIL" "Backend not responding - is it running?" "Start it with: START_BACKEND.bat"
    } else {
        Report-Test "Backend API (GET /users)" "FAIL" "$errMsg"
    }
}

# Test frontend on port 3000
Write-Host "`n  Checking if Frontend is running on http://localhost:3000..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Report-Test "Frontend (http://localhost:3000)" "PASS" "React app is serving"
    } else {
        Report-Test "Frontend (http://localhost:3000)" "WARN" "HTTP $($response.StatusCode)"
    }
} catch {
    Report-Test "Frontend (http://localhost:3000)" "FAIL" "Frontend not running" "Start it with: START_FRONTEND.bat"
}

# ============================================================================
# SECTION 6: PORT AVAILABILITY
# ============================================================================

Test-Section "6. PORT AVAILABILITY"

# Check port 8080
Write-Host "  Checking port 8080 (Backend)..." -ForegroundColor Gray
try {
    $netstat = & netstat -ano 2>&1 | findstr ":8080 "
    if ($netstat) {
        $pid = ($netstat -split '\s+')[-1]
        Report-Test "Port 8080 (Backend)" "PASS" "In use by PID: $pid"
    } else {
        Report-Test "Port 8080 (Backend)" "WARN" "No process found on port 8080"
    }
} catch {
    Report-Test "Port 8080 (Backend)" "WARN" "Could not check port status"
}

# Check port 3000
Write-Host "  Checking port 3000 (Frontend)..." -ForegroundColor Gray
try {
    $netstat = & netstat -ano 2>&1 | findstr ":3000 "
    if ($netstat) {
        $pid = ($netstat -split '\s+')[-1]
        Report-Test "Port 3000 (Frontend)" "PASS" "In use by PID: $pid"
    } else {
        Report-Test "Port 3000 (Frontend)" "WARN" "No process found on port 3000"
    }
} catch {
    Report-Test "Port 3000 (Frontend)" "WARN" "Could not check port status"
}

# ============================================================================
# SECTION 7: DATABASE VERIFICATION
# ============================================================================

Test-Section "7. DATABASE VERIFICATION"

# Check H2 Console
Write-Host "  Checking H2 Database Console..." -ForegroundColor Gray
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/h2-console" -TimeoutSec 2 -ErrorAction SilentlyContinue
    if ($response.StatusCode -eq 200) {
        Report-Test "H2 Console" "PASS" "http://localhost:8080/h2-console"
    } else {
        Report-Test "H2 Console" "WARN" "Available but HTTP $($response.StatusCode)"
    }
} catch {
    Report-Test "H2 Console" "FAIL" "Not accessible (backend running?)" "Backend must be running to access H2 console"
}

# ============================================================================
# SECTION 8: CODE VERIFICATION
# ============================================================================

Test-Section "8. CODE QUALITY CHECKS"

# Check if frontend/src/components/ProtectedRoute.js exists
if (Test-Path "frontend\src\components\ProtectedRoute.js") {
    Report-Test "ProtectedRoute Component" "PASS" "Route guard component present"
} else {
    Report-Test "ProtectedRoute Component" "FAIL" "Not found - routes may not be protected"
}

# Check api.js for axios interceptor
$apiFile = "frontend\src\services\api.js"
if (Test-Path $apiFile) {
    $apiContent = Get-Content $apiFile -Raw
    if ($apiContent -like "*interceptors*") {
        Report-Test "axios Interceptors" "PASS" "Request/response interceptors configured"
    } else {
        Report-Test "axios Interceptors" "WARN" "Interceptors not found"
    }
} else {
    Report-Test "axios Interceptors" "FAIL" "api.js not found"
}

# ============================================================================
# SECTION 9: DIAGNOSTIC CHECKS
# ============================================================================

Test-Section "9. DIAGNOSTIC CHECKS"

$diagnostics = 0

# Check if both services would start
if ((Test-Path "backend\src\main\java") -and (Test-Path "frontend\src")) {
    Report-Test "Project Structure" "PASS" "Both frontend and backend present"
    $diagnostics++
}

# Check if configuration is complete
if ((Test-Path "frontend\.env") -and (Test-Path "backend\src\main\resources\application.properties")) {
    Report-Test "Configuration" "PASS" "All config files in place"
    $diagnostics++
}

# Check if startup scripts exist
if ((Test-Path "START_BACKEND.bat") -or (Test-Path "START_FRONTEND.bat")) {
    Report-Test "Startup Scripts" "PASS" "Startup scripts available"
    $diagnostics++
}

# ============================================================================
# SECTION 10: SUMMARY & RECOMMENDATIONS
# ============================================================================

Test-Section "10. SUMMARY & RECOMMENDATIONS"

Write-Host ""
Write-Host "═" * 70
Write-Host "TEST RESULTS:" -ForegroundColor $info
Write-Host "═" * 70

Write-Host "Total Tests: $totalTests" -ForegroundColor Gray
Write-Host "Passed:      $passedTests" -ForegroundColor $success
Write-Host "Failed:      $failedTests" -ForegroundColor $error
Write-Host "Warnings:    $warnings" -ForegroundColor $warning

$passRate = if ($totalTests -gt 0) { [math]::Round(($passedTests / $totalTests) * 100, 1) } else { 0 }
Write-Host "Pass Rate:   $passRate%" -ForegroundColor $(if ($passRate -ge 80) { $success } else { $warning })

Write-Host "`n═" * 70
Write-Host "RECOMMENDATIONS:" -ForegroundColor $info
Write-Host "═" * 70
Write-Host ""

if ($failedTests -gt 0) {
    Write-Host "❌ FAILURES DETECTED - Action Required:" -ForegroundColor $error
    Write-Host ""
    
    if (-not (Test-Path "frontend\.env")) {
        Write-Host "1. Create frontend/.env:"
        Write-Host "   echo REACT_APP_API_URL=http://localhost:8080/api > frontend\.env`n"
    }
    
    Write-Host "2. Start Backend (in Terminal 1):"
    Write-Host "   cd backend"
    Write-Host "   mvn spring-boot:run`n"
    
    Write-Host "3. Start Frontend (in Terminal 2):"
    Write-Host "   cd frontend"
    Write-Host "   npm install"
    Write-Host "   npm start`n"
    
    Write-Host "4. Then run this script again to verify"
    Write-Host ""
} elseif ($warnings -gt 0) {
    Write-Host "⚠ WARNINGS DETECTED:" -ForegroundColor $warning
    Write-Host "Check the warnings above for details.`n"
    
    Write-Host "Next Steps:"
    Write-Host "1. Open http://localhost:3000 in your browser"
    Write-Host "2. Click Register and test the form"
    Write-Host "3. Verify no 'Network Error' appears"
    Write-Host "4. Check if user saved to database"
    Write-Host "5. Test Login → Dashboard → Logout flow`n"
} else {
    Write-Host "✓ ALL TESTS PASSED!" -ForegroundColor $success
    Write-Host ""
    Write-Host "Your full stack setup is complete and working!"
    Write-Host ""
    Write-Host "Quick Test:"
    Write-Host "1. Open browser: http://localhost:3000"
    Write-Host "2. Register a test user"
    Write-Host "3. Login with those credentials"
    Write-Host "4. Verify Dashboard displays"
    Write-Host "5. Test Logout and navigation`n"
}

Write-Host "═" * 70
Write-Host "For detailed troubleshooting, see:" -ForegroundColor $info
Write-Host "  • FIX_NETWORK_ERROR.md"
Write-Host "  • NETWORK_ERROR_TESTING_GUIDE.md"
Write-Host "  • README_NETWORK_ERROR_FIX.md"
Write-Host ""
Write-Host "═" * 70

Write-Host "`nPress any key to close..." -ForegroundColor $warning
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
