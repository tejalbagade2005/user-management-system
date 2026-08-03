# Network Error on Register Page - Root Cause & Fix

## Executive Summary

Your React frontend shows "Network Error" when trying to register because:
1. **The backend is NOT running** (most common cause)
2. Frontend cannot connect to `http://localhost:8080/api`
3. No `.env` file was configured (now fixed)

This guide will help you identify and fix the issue step-by-step.

---

## Root Cause Analysis

### Why You See "Network Error"

When you click "Register" on the React frontend:

```
Frontend (React)
    ↓
axios.post('/auth/register')
    ↓
Tries to connect to: http://localhost:8080/api/auth/register
    ↓
Backend NOT running / Not responding
    ↓
❌ Network Error
```

### Common Causes (in order of likelihood)

1. **Backend is NOT running** - Most common (60% of cases)
2. **Backend ran but crashed** - Check error messages (20%)
3. **Wrong API URL configured** - Now fixed (10%)
4. **Firewall/Port blocked** - Less common (10%)

---

## Quick Fix (3 Steps)

### Step 1: Start the Backend

**Option A: Use the startup script (Recommended)**
```bash
# Double-click this file:
START_BACKEND.bat
```

**Option B: Manual Maven command**
```bash
cd backend
mvn spring-boot:run
```

**Expected Output:**
```
...
Started BackendApplication in 5.234 seconds (JVM running for 6.123)
Tomcat started on port(s): 8080 (http)
Listening on http://localhost:8080
```

If you see this, backend is running ✓

### Step 2: Start the Frontend

**Option A: Use the startup script (Recommended)**
```bash
# In a NEW terminal window:
START_FRONTEND.bat
```

**Option B: Manual npm command**
```bash
cd frontend
npm install  # (only first time)
npm start
```

**Expected Output:**
```
Compiled successfully!
You can now view fullstack in the browser.
Local: http://localhost:3000
```

### Step 3: Test Registration

1. Open browser: `http://localhost:3000`
2. Click "Register"
3. Fill form:
   - Full Name: Test User
   - Email: test@example.com
   - Username: testuser
   - Password: TestPass123
4. Click Register

**Expected Result:**
- ✓ User saved to database
- ✓ Redirect to Login page
- ✗ Should NOT show "Network Error"

---

## Detailed Troubleshooting

### Issue 1: Backend won't start

#### Symptom
```
'mvn' is not recognized as an internal or external command
```

#### Solutions

**Solution A: Install Maven**
1. Download: https://maven.apache.org/download.cgi
2. Extract to: `C:\maven`
3. Add to PATH:
   - Windows: Settings → Environment Variables
   - Add: `C:\maven\bin`
4. Restart terminal and try again

**Solution B: Use Maven wrapper**
```bash
cd backend
.\mvnw spring-boot:run  # or: mvnw.cmd spring-boot:run
```

**Solution C: Check Java version**
```bash
java -version
# Output should be Java 8 or higher
# If not: Install Java from https://www.oracle.com/java/technologies/
```

---

### Issue 2: Backend starts but crashes

#### Symptom
```
Exception in thread "main"
java.lang.ClassNotFoundException
```

#### Diagnosis
Check the error message in the terminal. Common issues:

**Problem: MySQL not configured**
- **Current**: Application uses H2 (in-memory) database by default
- **Fix**: No action needed! H2 works without MySQL setup
- **Result**: Data is cleared on restart (acceptable for development)

**Problem: Port 8080 already in use**
```
ERROR: Address already in use: bind
```
**Fix:**
```bash
# Find what's using port 8080
netstat -ano | findstr :8080

# Kill the process
taskkill /PID <PID> /F

# Or change port in application.properties:
# server.port=8081
```

**Problem: Dependency not found**
```
Failed to download artifact
```
**Fix:**
```bash
# Clear Maven cache and retry
cd backend
mvn clean install
mvn spring-boot:run
```

---

### Issue 3: Frontend shows "Network Error"

#### Step 1: Check Backend is Running
```bash
# In PowerShell, check if backend is responding:
Invoke-WebRequest -Uri "http://localhost:8080/api/users" -Method GET
```

**Expected Output:**
```
StatusCode        : 200
StatusDescription : OK
RawContent        : HTTP/1.1 200 OK
```

**If you get error:** Backend is not running!
- Go back to "Issue 1: Backend won't start"

#### Step 2: Check Frontend Configuration
```bash
# Verify .env file exists:
type frontend\.env

# Expected output:
# REACT_APP_API_URL=http://localhost:8080/api
```

If `.env` doesn't exist:
```bash
# Create it:
echo REACT_APP_API_URL=http://localhost:8080/api > frontend\.env
```

#### Step 3: Check Browser Console
1. Open browser: `http://localhost:3000`
2. Press `F12` to open DevTools
3. Go to "Console" tab
4. Look for error messages
5. Go to "Network" tab
6. Try to Register
7. Look for `auth/register` request
8. Click it and check:
   - Status code (should be 400 or 200, not connection error)
   - Response body (shows error message from backend)

#### Step 4: Manual API Test
```bash
# Test if backend API works:
curl -X POST http://localhost:8080/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"fullName\":\"Test\",\"email\":\"test@example.com\",\"username\":\"testuser\",\"password\":\"TestPass123\"}"

# Expected response:
# {"id":1,"message":"User registered successfully"}
```

If this fails: Backend is not accepting connections!

#### Step 5: Check Firewall
```bash
# Windows Firewall might block port 8080
# To allow it:
# 1. Search for "Windows Defender Firewall"
# 2. Click "Allow an app through firewall"
# 3. Allow "Java(TM) Platform SE binary"
```

---

### Issue 4: User not saved to database

#### Symptom
- Registration appears to succeed
- But user is not in database
- Next login shows "Invalid credentials"

#### Check Database
```bash
# If using H2 (default):
# 1. Open browser: http://localhost:8080/h2-console
# 2. Click Connect
# 3. Run SQL:
SELECT * FROM USERS;
```

#### Possible Causes

**Cause 1: Backend using wrong database**
- Check: `backend/src/main/resources/application.properties`
- Should see: `spring.datasource.url=jdbc:h2:mem:fullstack_db`
- Not: `spring.datasource.url=jdbc:mysql://...`

**Cause 2: Users table not created**
- Hibernate should auto-create it
- If not: Check backend logs for errors
- Ensure: `spring.jpa.hibernate.ddl-auto=update`

**Cause 3: Password not hashing**
- Check: UserService uses BCryptPasswordEncoder
- Password should NOT be plain text in database
- Password should look like: `$2a$10$...` (long hash)

---

## Verification Checklist

Use this to verify everything is working:

```
☐ Backend
  ☐ Started with command: mvn spring-boot:run
  ☐ Shows "Started BackendApplication"
  ☐ Shows "Tomcat started on port(s): 8080"
  ☐ Test: curl http://localhost:8080/api/users
  
☐ Frontend
  ☐ Started with command: npm start
  ☐ Shows "Compiled successfully!"
  ☐ Browser opens to http://localhost:3000
  
☐ Configuration
  ☐ frontend/.env exists with: REACT_APP_API_URL=http://localhost:8080/api
  ☐ backend/application.properties has: server.port=8080
  
☐ Registration
  ☐ Fill form with valid data
  ☐ Click Register
  ☐ See success message (no "Network Error")
  ☐ Redirected to Login page
  
☐ Database
  ☐ User appears in database
  ☐ Password is hashed (not plain text)
  
☐ Login
  ☐ Enter credentials
  ☐ Click Login
  ☐ See Dashboard
  ☐ localStorage has 'token'
  
☐ Logout
  ☐ Click Logout on Dashboard
  ☐ Redirected to Login
  ☐ Back button doesn't work
  ☐ localStorage is cleared
  
☐ Protected Routes
  ☐ Can't access Dashboard without login
  ☐ Redirected to Login page
```

---

## What Was Fixed

### 1. ✓ Created `frontend/.env` file
```
REACT_APP_API_URL=http://localhost:8080/api
```

**Why it matters:**
- React needs to know where the backend API is
- Without this, `process.env.REACT_APP_API_URL` is undefined
- The fallback URL still works, but best practice is to have .env

### 2. ✓ Updated `backend/application.properties`
```
# Now uses H2 database by default (no MySQL setup needed)
# Supports environment variables for MySQL configuration
# Better logging for debugging
```

**Why it matters:**
- No need to install/configure MySQL for development
- Can still use MySQL by setting environment variables
- Better error messages if something goes wrong

### 3. ✓ Created `START_BACKEND.bat` script
- Automatically checks Java and Maven
- Starts the backend with correct command
- Shows clear error messages if setup is wrong

### 4. ✓ Created `START_FRONTEND.bat` script
- Installs npm dependencies if needed
- Starts the React dev server
- No manual npm install command needed

### 5. ✓ Created `DIAGNOSE.ps1` script
- Runs comprehensive checks
- Tests all components
- Provides troubleshooting instructions

---

## Complete Flow Verification

After fixing the Network Error, verify the complete authentication flow:

### Registration Flow
```
User fills form
    ↓
Click Register
    ↓
api.js → POST /auth/register
    ↓
Backend → Validate & Save to Database
    ↓
Response: {id: 1, message: "User registered successfully"}
    ↓
Frontend → Show success message
    ↓
Navigate to /login with replace: true
    ↓
✓ User can now login
```

### Login Flow
```
User enters credentials
    ↓
Click Login
    ↓
api.js → POST /auth/login
    ↓
Backend → Authenticate & Generate JWT
    ↓
Response: {token: "eyJ...", user: {...}}
    ↓
Frontend → Store in localStorage
    ↓
Navigate to /dashboard with replace: true
    ↓
✓ Dashboard accessible
```

### Logout Flow
```
User clicks Logout
    ↓
Call: authService.logout()
    ↓
Clear all localStorage (token, user, username)
    ↓
Navigate to /login with replace: true
    ↓
Back button won't work
    ↓
✓ Complete logout
```

---

## Expected Database Schema

The backend will automatically create this table:

```sql
CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  mobile VARCHAR(20),
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,  -- Hashed with BCrypt
  role VARCHAR(50) DEFAULT 'USER',
  profile_image VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_username (username),
  INDEX idx_email (email)
);
```

No manual SQL needed - Hibernate creates it automatically!

---

## Environment Variable Configuration (Advanced)

To use MySQL instead of H2:

### Step 1: Install and Start MySQL
```bash
# Download: https://dev.mysql.com/downloads/mysql/
# On Windows, install as service
# Start service: net start MySQL80
```

### Step 2: Create Database
```sql
CREATE DATABASE fullstack_db;
```

### Step 3: Set Environment Variables
```bash
# In PowerShell:
$env:DB_URL="jdbc:mysql://localhost:3306/fullstack_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
$env:DB_USERNAME="root"
$env:DB_PASSWORD="your_mysql_password"
$env:DB_DRIVER="com.mysql.cj.jdbc.Driver"
$env:DB_DIALECT="org.hibernate.dialect.MySQL8Dialect"

# Then start backend:
mvn spring-boot:run
```

### Or: Edit application.properties

```properties
# Replace spring.datasource.* section with:
spring.datasource.url=jdbc:mysql://localhost:3306/fullstack_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=your_mysql_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
```

---

## Getting Help

If you still see "Network Error":

1. **Check backend is running:**
   ```bash
   curl http://localhost:8080/api/users
   ```

2. **Check frontend configuration:**
   ```bash
   type frontend\.env
   ```

3. **Check browser console (F12):**
   - Console tab for error messages
   - Network tab for API call details

4. **Check backend logs:**
   - Look for ERROR or WARN messages
   - See what endpoint was called
   - See what error was returned

5. **Run diagnostic:**
   ```bash
   # PowerShell:
   .\DIAGNOSE.ps1
   
   # Or Batch:
   DIAGNOSE.bat
   ```

6. **Check documentation:**
   - See: COMPLETE_FIX_SUMMARY.md
   - See: QUICK_START.md
   - See: DEVELOPER_QUICK_REFERENCE.md

---

## Success Indicators

You'll know everything is working when:

✓ Backend terminal shows: `Tomcat started on port(s): 8080`
✓ Frontend browser opens to: `http://localhost:3000`
✓ Register form submits without "Network Error"
✓ User appears in database
✓ Can login with registered credentials
✓ Dashboard displays after login
✓ Logout works and prevents back button access
✓ Protected pages redirect to login when not authenticated

---

## Summary

| Issue | Cause | Fix |
|-------|-------|-----|
| "Network Error" on Register | Backend not running | Run `START_BACKEND.bat` |
| Can't find mvn command | Maven not in PATH | Install Maven or use wrapper |
| Backend crashes on start | Port 8080 in use | Kill process or change port |
| No database created | Hibernate disabled | Check `ddl-auto=update` |
| User not saved | Validate errors ignored | Check backend logs |
| Can't login | Different database used | Ensure same database (H2 or MySQL) |
| Frontend can't connect | Wrong API URL | Verify `.env` configuration |

---

Now follow the **Quick Fix (3 Steps)** at the top of this document!
