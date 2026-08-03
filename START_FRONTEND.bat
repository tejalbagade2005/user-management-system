@echo off
REM ============================================================================
REM Frontend Startup Script
REM ============================================================================
REM This script will start the React development server on http://localhost:3000
REM Make sure the backend is already running on http://localhost:8080
REM ============================================================================

echo.
echo ============================================================================
echo Full Stack Application - Frontend Startup
echo ============================================================================
echo.

cd /d "%~dp0frontend"

if not exist "node_modules" (
    echo Dependencies not installed. Installing now...
    echo This may take a few minutes...
    call npm install
    if %errorlevel% neq 0 (
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

echo.
echo Starting React development server...
echo The application will open at http://localhost:3000
echo.
echo Make sure the backend is running on http://localhost:8080
echo.

call npm start

pause
