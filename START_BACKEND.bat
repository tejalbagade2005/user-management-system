@echo off
REM ============================================================================
REM Full Stack Application Startup Script
REM ============================================================================
REM This script will:
REM 1. Check if Java and Maven are installed
REM 2. Build and start the Spring Boot backend
REM 3. Keep it running while you test with the React frontend
REM ============================================================================

echo.
echo ============================================================================
echo Full Stack Application - Backend Startup
echo ============================================================================
echo.

REM Check Java
echo [1/3] Checking Java installation...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Java is not installed or not in PATH
    echo Please install Java 8 or later
    pause
    exit /b 1
)
echo OK: Java found
echo.

REM Check for Maven in PATH
echo [2/3] Checking Maven installation...
mvn -version >nul 2>&1
if %errorlevel% equ 0 (
    echo OK: Maven found in PATH
    echo.
    echo [3/3] Building and starting backend...
    call mvn spring-boot:run -f "%~dp0..\backend\pom.xml"
) else (
    echo Maven not found in PATH. Checking for local installation...
    
    REM Check if Maven wrapper exists in backend
    if exist "%~dp0..\backend\mvnw.cmd" (
        echo OK: Maven wrapper found
        echo.
        echo [3/3] Building and starting backend using Maven wrapper...
        call "%~dp0..\backend\mvnw.cmd" spring-boot:run
    ) else (
        echo ERROR: Maven not found
        echo.
        echo Please install Maven from: https://maven.apache.org/download.cgi
        echo And add it to your PATH, or run this script from the project directory
        echo.
        echo Alternative: Run this command manually in the backend directory:
        echo   mvn spring-boot:run
        echo.
        pause
        exit /b 1
    )
)

echo.
echo Backend startup complete. The application will continue running.
echo To stop, press Ctrl+C
pause
