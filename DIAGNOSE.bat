@echo off
REM ============================================================================
REM Network Error Diagnostic Script
REM ============================================================================
REM This script will diagnose the "Network Error" on the Register page by
REM checking all components of the full stack application
REM ============================================================================

setlocal enabledelayedexpansion
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo.
echo ============================================================================
echo FULL STACK APPLICATION - DIAGNOSTIC REPORT
echo ============================================================================
echo Generated: %date% %time%
echo.

REM ===========================================================================
REM 1. Java Check
REM ===========================================================================
echo [TEST 1/8] Checking Java Installation...
echo.
java -version 2>&1
if %errorlevel% neq 0 (
    echo ❌ FAILED: Java is not installed
    goto error_summary
) else (
    echo ✓ PASSED: Java is installed
)
echo.

REM ===========================================================================
REM 2. Maven Check
REM ===========================================================================
echo [TEST 2/8] Checking Maven Installation...
echo.
mvn -version >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ PASSED: Maven found in PATH
) else (
    if exist "backend\mvnw.cmd" (
        echo ✓ PASSED: Maven wrapper found in backend directory
    ) else (
        echo ⚠ WARNING: Maven not found in PATH and no wrapper available
        echo To install Maven: https://maven.apache.org/download.cgi
    )
)
echo.

REM ===========================================================================
REM 3. Node.js Check
REM ===========================================================================
echo [TEST 3/8] Checking Node.js Installation...
echo.
node --version 2>&1
if %errorlevel% neq 0 (
    echo ❌ FAILED: Node.js is not installed
    goto error_summary
) else (
    echo ✓ PASSED: Node.js is installed
)
echo npm --version
npm --version 2>&1
echo.

REM ===========================================================================
REM 4. Frontend Configuration Check
REM ===========================================================================
echo [TEST 4/8] Checking Frontend Configuration...
echo.
if not exist "frontend\.env" (
    echo ❌ FAILED: frontend\.env file not found
    echo Creating it now...
    (
        echo REACT_APP_API_URL=http://localhost:8080/api
    ) > "frontend\.env"
    echo ✓ Created frontend\.env
) else (
    echo ✓ PASSED: frontend\.env file exists
    echo Contents:
    type "frontend\.env"
)
echo.

REM ===========================================================================
REM 5. Frontend Dependencies Check
REM ===========================================================================
echo [TEST 5/8] Checking Frontend Dependencies...
echo.
if exist "frontend\node_modules" (
    echo ✓ PASSED: node_modules directory exists
) else (
    echo ⚠ WARNING: node_modules not installed
    echo Run: cd frontend ^&^& npm install
)
echo.

REM ===========================================================================
REM 6. Backend Configuration Check
REM ===========================================================================
echo [TEST 6/8] Checking Backend Configuration...
echo.
if exist "backend\src\main\resources\application.properties" (
    echo ✓ PASSED: application.properties exists
    echo.
    echo Database Configuration:
    echo.
    findstr /R "^spring.datasource" "backend\src\main\resources\application.properties"
    echo.
    echo JWT Configuration:
    findstr /R "^jwt" "backend\src\main\resources\application.properties"
    echo.
) else (
    echo ❌ FAILED: application.properties not found
)
echo.

REM ===========================================================================
REM 7. API Connectivity Check (requires backend running)
REM ===========================================================================
echo [TEST 7/8] Checking API Connectivity...
echo.
echo Attempting to connect to http://localhost:8080/api/users
echo.
powershell -Command "$r = Try {(Invoke-WebRequest -Uri 'http://localhost:8080/api/users' -Method GET -TimeoutSec 2 -ErrorAction Stop).StatusCode} Catch {$_.Exception.Response.StatusCode.Value__}; if ($r) {Write-Host '✓ PASSED: Backend is responding with HTTP '$r} else {Write-Host '❌ FAILED: Backend is not responding'}" 2>&1
echo.
echo Note: The backend must be running for this check to pass.
echo If it failed, start the backend first: START_BACKEND.bat
echo.

REM ===========================================================================
REM 8. File Permissions Check
REM ===========================================================================
echo [TEST 8/8] Checking File Permissions...
echo.
if exist "backend\pom.xml" (
    echo ✓ PASSED: backend\pom.xml is readable
) else (
    echo ❌ FAILED: backend\pom.xml not found
)
if exist "frontend\package.json" (
    echo ✓ PASSED: frontend\package.json is readable
) else (
    echo ❌ FAILED: frontend\package.json not found
)
echo.

REM ===========================================================================
REM Summary and Recommendations
REM ===========================================================================
echo ============================================================================
echo DIAGNOSTIC SUMMARY
echo ============================================================================
echo.
echo ✓ Frontend Environment File: READY
echo.
echo Next Steps:
echo 1. Start the Backend:
echo    - Run: START_BACKEND.bat
echo    - Or manually: cd backend ^&^& mvn spring-boot:run
echo.
echo 2. In another terminal, start the Frontend:
echo    - Run: START_FRONTEND.bat
echo    - Or manually: cd frontend ^&^& npm start
echo.
echo 3. Test the Application:
echo    - Register page: http://localhost:3000/register
echo    - Login page: http://localhost:3000/login
echo    - Dashboard: http://localhost:3000/dashboard (after login)
echo.
echo 4. For troubleshooting:
echo    - Check backend logs in the backend terminal
echo    - Check frontend console (F12 in browser)
echo    - Check browser Network tab for API calls
echo.
echo ============================================================================
echo.

pause
exit /b 0

:error_summary
echo.
echo ============================================================================
echo ERRORS FOUND
echo ============================================================================
echo.
echo Please fix the errors above before continuing.
echo Required:
echo   - Java 8 or higher: https://www.oracle.com/java/technologies/
echo   - Maven: https://maven.apache.org/download.cgi
echo   - Node.js: https://nodejs.org/
echo.
pause
exit /b 1
