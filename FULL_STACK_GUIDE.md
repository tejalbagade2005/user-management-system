# FULL STACK PROJECT - COMPLETE GUIDE

**Status:** Ready to run ✅
**Project:** React + Spring Boot + H2/MySQL
**Issue:** "Network Error" on Register page - FIXED ✅

---

## Table of Contents

1. [Quick Start (5 minutes)](#quick-start)
2. [What's Included](#whats-included)
3. [Architecture Overview](#architecture)
4. [How to Run](#how-to-run)
5. [If Something Goes Wrong](#troubleshooting)
6. [Features & What Was Fixed](#features)
7. [Database](#database)
8. [API Reference](#api-reference)
9. [Security](#security)
10. [Next Steps](#next-steps)

---

## Quick Start

### Prerequisites Check
```bash
java -version        # Should show Java 1.8+
node --version       # Should show Node.js
npm --version        # Should show npm
```

### Run in 3 Commands

**Terminal 1:**
```bash
cd d:\IT Vedant Intern1\backend
mvn spring-boot:run
```
Wait for: `Tomcat started on port(s): 8080`

**Terminal 2 (New):**
```bash
cd d:\IT Vedant Intern1\frontend
npm start
```
Wait for: Browser opens to http://localhost:3000

**Browser:**
- Register a user
- Login with those credentials
- View Dashboard
- Logout

---

## What's Included

### Frontend (React)
- ✓ User Registration with form validation
- ✓ User Login with JWT authentication
- ✓ Protected Dashboard (requires login)
- ✓ User Profile listing
- ✓ Logout with secure token clearing
- ✓ Error handling and user feedback
- ✓ Responsive UI with Bootstrap

### Backend (Spring Boot)
- ✓ User registration endpoint
- ✓ User login endpoint
- ✓ JWT token generation and validation
- ✓ Password hashing with BCrypt
- ✓ Protected API endpoints
- ✓ User listing endpoint
- ✓ CORS configuration for frontend
- ✓ Spring Security integration

### Database
- ✓ H2 in-memory database (default, zero setup)
- ✓ Optional MySQL support
- ✓ Automatic table creation
- ✓ User table with hashed passwords

### Configuration
- ✓ Environment variables support
- ✓ Application properties file
- ✓ Frontend .env file
- ✓ JWT token settings
- ✓ Database configuration

---

## Architecture Overview

### System Diagram
```
┌─────────────────────────────────────────────────────────────┐
│                    USER BROWSER                             │
│               (http://localhost:3000)                        │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  React Application                                    │  │
│  │  • Pages: Register, Login, Dashboard, Profile         │  │
│  │  • Services: api.js (Axios), authService.js          │  │
│  │  • State: localStorage (token, user)                  │  │
│  └───────────────────────────────────────────────────────┘  │
│                         ↓ ↑ (HTTP/CORS)                      │
│                                                               │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Spring Boot Backend                                │    │
│  │  (http://localhost:8080/api)                        │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ REST Endpoints:                               │  │    │
│  │  │ • POST   /auth/register    → UserRepository  │  │    │
│  │  │ • POST   /auth/login       → JwtUtil         │  │    │
│  │  │ • GET    /users            → Query all users │  │    │
│  │  │ • PUT    /users/{id}       → Update user     │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  │                         ↓                           │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ Security Layer:                               │  │    │
│  │  │ • SecurityConfig: defines access rules       │  │    │
│  │  │ • JwtFilter: validates tokens                │  │    │
│  │  │ • JwtUtil: generates/verifies tokens         │  │    │
│  │  │ • BCryptPasswordEncoder: hashes passwords    │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  │                         ↓                           │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ Database Layer:                               │  │    │
│  │  │ • UserRepository (Spring Data JPA)           │  │    │
│  │  │ • User Entity (JPA mapped)                   │  │    │
│  │  │ • H2 or MySQL connection                     │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────────────────────────────────────────────┐    │
│  │  Database (H2 or MySQL)                             │    │
│  │  ┌───────────────────────────────────────────────┐  │    │
│  │  │ USERS Table:                                  │  │    │
│  │  │ • id (AUTO_INCREMENT)                         │  │    │
│  │  │ • full_name                                   │  │    │
│  │  │ • email (UNIQUE)                              │  │    │
│  │  │ • mobile                                       │  │    │
│  │  │ • username (UNIQUE)                           │  │    │
│  │  │ • password (BCrypt hashed)                    │  │    │
│  │  │ • role (default: 'USER')                      │  │    │
│  │  │ • created_at (TIMESTAMP)                      │  │    │
│  │  └───────────────────────────────────────────────┘  │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

### Data Flow Diagram

**Registration Flow:**
```
User → Register Form → React → api.post('/auth/register')
    ↓
axios (with baseURL: http://localhost:8080/api)
    ↓
Spring Boot REST Controller
    ↓
UserService.register(user)
    ↓
Password Hashing (BCrypt)
    ↓
UserRepository.save(user)
    ↓
H2/MySQL Database
    ↓
Response: {id, message}
    ↓
React → Success Message → Redirect to Login
```

**Login Flow:**
```
User → Login Form → React → api.post('/auth/login')
    ↓
Spring Boot REST Controller
    ↓
UserRepository.findByUsername(username)
    ↓
Password Verification (BCrypt compare)
    ↓
JwtUtil.generateToken(user)
    ↓
Response: {token: "JWT...", user: {...}}
    ↓
React → Store in localStorage → Redirect to Dashboard
```

**Protected API Call:**
```
Dashboard → api.get('/users')
    ↓
Axios adds header: Authorization: Bearer {token from localStorage}
    ↓
Spring Boot Servlet Filter
    ↓
JwtFilter checks Authorization header
    ↓
JwtUtil validates token
    ↓
If valid: Process request → Return data
If invalid: Return 401 Unauthorized → Frontend redirects to login
```

---

## How to Run

### Step 1: Install Prerequisites (First Time Only)

```bash
# Install Java (if not already installed)
# Download from: https://www.oracle.com/java/technologies/

# Install Maven (if not in PATH)
# Option A: Download from https://maven.apache.org/download.cgi
# Option B: Use wrapper (already in backend folder)

# Install Node.js
# Download from: https://nodejs.org/
```

### Step 2: Configure Frontend

```bash
# Navigate to frontend
cd frontend

# Create .env file (if not exists)
echo REACT_APP_API_URL=http://localhost:8080/api > .env

# Install npm packages (first time or if node_modules deleted)
npm install
```

### Step 3: Start Backend

```bash
cd backend

# Option A: Use provided script
START_BACKEND.bat

# Option B: Use Maven directly
mvn spring-boot:run

# Option C: Use Maven wrapper
.\mvnw spring-boot:run

# Expected output:
# Started BackendApplication in X.XXX seconds (JVM running for Y.YYY)
# Tomcat started on port(s): 8080 (http)
```

### Step 4: Start Frontend (New Terminal)

```bash
cd frontend

# Option A: Use provided script
START_FRONTEND.bat

# Option B: Use npm directly
npm start

# Expected output:
# Compiled successfully!
# You can now view frontend in the browser.
# Local: http://localhost:3000
```

### Step 5: Open in Browser

```
http://localhost:3000
```

---

## Troubleshooting

### "Network Error" on Register Page

**Cause:** Backend is not running or not responding

**Solution:**
1. Make sure backend terminal shows "Tomcat started on port 8080"
2. Test: `curl http://localhost:8080/api/users`
3. If connection refused: Start backend with `START_BACKEND.bat`

**Debug:**
- Check backend terminal for errors
- Open browser F12 → Network tab
- Look for auth/register request
- Check response status and body

---

### Maven not found

**Solution:**
```bash
cd backend
.\mvnw spring-boot:run  # Use wrapper instead of mvn
```

---

### Port 8080 already in use

**Solution:**
```bash
# Find what's using port 8080
netstat -ano | findstr :8080

# Kill the process
taskkill /PID <PID> /F

# Or change port in: backend/src/main/resources/application.properties
# Add: server.port=8081
```

---

### Cannot see database

**H2 Console:**
```
http://localhost:8080/h2-console
```

**MySQL Command Line:**
```bash
mysql -u root -p fullstack_db
mysql> SELECT * FROM USERS;
```

---

### Stuck after login

**Solution:**
1. Check browser localStorage: F12 → Application → Local Storage
2. Should have keys: token, user, username
3. If empty: Token not stored (check backend login response)
4. Hard refresh: Ctrl+Shift+R

---

For more troubleshooting, see: **FIX_NETWORK_ERROR.md**

---

## Features

### ✅ Registration
- Form validation (email format, password strength)
- Duplicate user prevention (email and username unique)
- Password hashing with BCrypt
- Automatic user role assignment (USER)
- Success message on registration
- Redirect to Login page

### ✅ Login
- Username and password authentication
- JWT token generation
- Token stored in localStorage
- User object stored in localStorage
- Auto-redirect to Dashboard on success
- Clear error messages on failure
- Auto-redirect to Dashboard if already logged in

### ✅ Dashboard
- Shows "Welcome back, {username}"
- Displays user information
- Logout button
- Protected route (can't access without login)
- Auto-redirect to Login if token missing
- Secure logout that clears all data

### ✅ User Profile
- List of all registered users
- User details display
- Protected route
- Can access after login

### ✅ Protected Routes
- Login page (bypass if already logged in)
- Dashboard (redirects to Login if not authenticated)
- Profile (redirects to Login if not authenticated)
- API calls include JWT token in header

### ✅ Security
- Password hashing (BCrypt)
- JWT token authentication
- Token expiration (24 hours default)
- Auto-logout on token expiration
- CORS configured
- SQL injection prevention
- Secure session management

### ✅ Error Handling
- Specific error messages (not generic)
- Form validation errors
- API error responses
- Backend error logging
- Frontend console logging
- User-friendly error display

---

## Database

### H2 (Default - Recommended for Development)

**Advantages:**
- Zero setup required
- Built into Spring Boot
- Perfect for development/testing
- In-memory or file-based
- Easy to inspect with console

**Disadvantages:**
- Data lost on restart
- Only accessible from same JVM
- Not for production

**Access:**
- Console: http://localhost:8080/h2-console
- Default database: fullstack_db
- Default user: sa (no password)

---

### MySQL (Optional - For Production)

**Setup:**
```bash
# 1. Install MySQL
# 2. Create database
mysql -u root -p
mysql> CREATE DATABASE fullstack_db;

# 3. Set environment variables (Windows)
# PowerShell:
$env:DB_URL="jdbc:mysql://localhost:3306/fullstack_db"
$env:DB_USERNAME="root"
$env:DB_PASSWORD="your_password"
$env:DB_DRIVER="com.mysql.cj.jdbc.Driver"
$env:DB_DIALECT="org.hibernate.dialect.MySQL8Dialect"

# 4. Start backend (will connect to MySQL)
mvn spring-boot:run

# 5. Access database
mysql -u root -p fullstack_db
mysql> SELECT * FROM USERS;
```

---

## API Reference

### Register
```
POST http://localhost:8080/api/auth/register
Content-Type: application/json

Request:
{
  "fullName": "John Doe",
  "email": "john@example.com",
  "mobile": "1234567890",
  "username": "johndoe",
  "password": "Password123"
}

Response (200):
{
  "id": 1,
  "message": "User registered successfully"
}

Errors:
- 400: Validation error (check response body)
- 409: Email or username already exists
- 500: Server error (check backend logs)
```

---

### Login
```
POST http://localhost:8080/api/auth/login
Content-Type: application/json

Request:
{
  "username": "johndoe",
  "password": "Password123"
}

Response (200):
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "role": "USER"
  }
}

Errors:
- 401: Invalid credentials
- 400: Missing username or password
- 500: Server error
```

---

### Get All Users
```
GET http://localhost:8080/api/users
Authorization: Bearer {token}

Response (200):
[
  {
    "id": 1,
    "username": "johndoe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "role": "USER"
  },
  ...
]

Errors:
- 401: Missing or invalid token
- 500: Server error
```

---

### Get User by ID
```
GET http://localhost:8080/api/users/{id}
Authorization: Bearer {token}

Response (200):
{
  "id": 1,
  "username": "johndoe",
  "email": "john@example.com",
  "fullName": "John Doe",
  "role": "USER"
}

Errors:
- 401: Missing or invalid token
- 404: User not found
- 500: Server error
```

---

## Security

### What's Protected

- ✓ Passwords hashed with BCrypt
- ✓ JWT tokens for authentication
- ✓ Tokens expire after 24 hours
- ✓ CORS configured (only localhost:3000)
- ✓ Protected endpoints require valid token
- ✓ SQL injection prevention (Hibernate)
- ✓ Auto-logout on token expiration
- ✓ Route guards prevent unauthorized access

### What's NOT Protected (By Design)

- ✗ Registration endpoint (anyone can register)
- ✗ Login endpoint (anyone can login)
- ✗ Get all users (public endpoint)
- ✗ Get user by ID (public endpoint)

---

## Configuration Files

### frontend/.env
```
REACT_APP_API_URL=http://localhost:8080/api
```

### backend/application.properties
```
# Server port
server.port=8080

# H2 Database (Default)
spring.datasource.url=jdbc:h2:mem:fullstack_db
spring.datasource.driverClassName=org.h2.Driver
spring.datasource.username=sa
spring.datasource.password=

# Or MySQL (if using environment variables)
spring.datasource.url=${DB_URL:jdbc:h2:mem:fullstack_db}
spring.datasource.username=${DB_USERNAME:sa}
spring.datasource.password=${DB_PASSWORD:}

# Hibernate
spring.jpa.database-platform=org.hibernate.dialect.H2Dialect
spring.jpa.hibernate.ddl-auto=update

# JWT
jwt.secret=your-secret-key-here
jwt.expiration=86400000

# H2 Console
spring.h2.console.enabled=true
spring.h2.console.path=/h2-console
```

---

## Next Steps

1. ✅ Run backend and frontend
2. ✅ Test registration and login
3. ✅ Verify database
4. ⬜ Review code and understand architecture
5. ⬜ Test with MySQL (optional)
6. ⬜ Deploy to production (when ready)

---

## File Structure

```
project-root/
├── START_BACKEND.bat
├── START_FRONTEND.bat
├── DIAGNOSE.ps1
├── VERIFY.ps1
├── README_NETWORK_ERROR_FIX.md
├── FIX_NETWORK_ERROR.md
├── NETWORK_ERROR_TESTING_GUIDE.md
├── COMPLETE_FIX_SUMMARY.md
├── QUICK_START.md
├── DEVELOPER_QUICK_REFERENCE.md
├── DOCUMENTATION_INDEX.md
├── FULL_STACK_GUIDE.md (this file)
│
├── frontend/
│   ├── .env
│   ├── package.json
│   ├── public/
│   ├── src/
│   │   ├── App.js
│   │   ├── App.css
│   │   ├── index.js
│   │   ├── components/
│   │   │   └── ProtectedRoute.js
│   │   ├── pages/
│   │   │   ├── Home.js
│   │   │   ├── Register.js
│   │   │   ├── Login.js
│   │   │   ├── Dashboard.js
│   │   │   └── Profile.js
│   │   └── services/
│   │       ├── api.js
│   │       └── authService.js
│   └── build/
│
└── backend/
    ├── pom.xml
    ├── src/main/
    │   ├── java/com/example/backend/
    │   │   ├── BackendApplication.java
    │   │   ├── controller/
    │   │   │   ├── AuthController.java
    │   │   │   └── UserController.java
    │   │   ├── service/
    │   │   │   ├── UserService.java
    │   │   │   └── CustomUserDetailsService.java
    │   │   ├── repository/
    │   │   │   └── UserRepository.java
    │   │   ├── model/
    │   │   │   └── User.java
    │   │   ├── dto/
    │   │   │   └── UserDTO.java
    │   │   └── security/
    │   │       ├── SecurityConfig.java
    │   │       ├── JwtUtil.java
    │   │       ├── JwtFilter.java
    │   │       └── CustomUserDetailsService.java
    │   └── resources/
    │       └── application.properties
    └── target/
```

---

## Summary

| Component | Status | Port | Command |
|-----------|--------|------|---------|
| Backend | Running | 8080 | `START_BACKEND.bat` |
| Frontend | Running | 3000 | `START_FRONTEND.bat` |
| Database | Ready | - | H2 Console: http://localhost:8080/h2-console |
| API | Ready | 8080 | http://localhost:8080/api |

---

## Common Ports

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3000 | http://localhost:3000 |
| Backend | 8080 | http://localhost:8080/api |
| H2 Console | 8080 | http://localhost:8080/h2-console |
| MySQL | 3306 | localhost:3306 (if using MySQL) |

---

**You're all set! Run START_BACKEND.bat and START_FRONTEND.bat to get started! 🚀**

For detailed information about specific components, see the other documentation files.
