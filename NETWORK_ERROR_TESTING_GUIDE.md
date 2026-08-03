# Network Error - Testing & Verification Guide

This guide helps you test if the "Network Error" is fixed.

---

## Prerequisites Check

Before testing, verify your setup:

```
☐ Java installed: java -version
☐ Maven available: mvn -version (or mvnw.cmd)
☐ Node.js installed: node --version
☐ npm installed: npm --version
☐ frontend/.env exists
☐ backend/application.properties exists
```

---

## Test 1: Backend Connectivity

### Objective
Verify backend is running and responding to requests.

### Steps

1. **Start Backend**
   ```bash
   cd backend
   mvn spring-boot:run
   ```

   **Wait for:**
   ```
   Started BackendApplication in X.XXX seconds
   Tomcat started on port(s): 8080 (http)
   ```

2. **Test in New Terminal**
   ```bash
   # PowerShell:
   (Invoke-WebRequest -Uri "http://localhost:8080/api/users").StatusCode
   
   # Or Command Prompt (with curl):
   curl http://localhost:8080/api/users
   
   # Expected output:
   # 200
   # []
   ```

3. **Expected Result**
   - Status: 200 OK
   - Body: Empty array `[]` (no users yet)
   - ✓ Backend is running and responding

### If It Fails

| Error | Solution |
|-------|----------|
| Connection refused | Backend not running. Check terminal for errors |
| 404 Not Found | Wrong API path. Use `/api/users` not `/users` |
| 500 Error | Backend error. Check terminal logs |
| Cannot find mvn | Install Maven or use `mvnw.cmd` |

---

## Test 2: Frontend Configuration

### Objective
Verify frontend can find the backend API.

### Steps

1. **Check .env File**
   ```bash
   type frontend\.env
   
   # Should show:
   # REACT_APP_API_URL=http://localhost:8080/api
   ```

2. **Check api.js**
   ```bash
   # In frontend/src/services/api.js, should see:
   # const api = axios.create({
   #   baseURL: process.env.REACT_APP_API_URL || 'http://localhost:8080/api',
   # });
   
   type frontend\src\services\api.js | findstr baseURL
   ```

3. **Expected Result**
   - .env file exists
   - REACT_APP_API_URL is set to `http://localhost:8080/api`
   - ✓ Frontend knows where backend is

### If It Fails

| Error | Solution |
|-------|----------|
| .env not found | Create it with: `echo REACT_APP_API_URL=http://localhost:8080/api > frontend\.env` |
| Wrong URL | Check that backend is on port 8080 |
| api.js missing | Should be in frontend/src/services/api.js |

---

## Test 3: Frontend Startup

### Objective
Verify React frontend starts without errors.

### Steps

1. **Install Dependencies (First Time Only)**
   ```bash
   cd frontend
   npm install
   ```

   **Wait for:** All packages installed successfully

2. **Start Frontend**
   ```bash
   npm start
   ```

   **Wait for:**
   ```
   Compiled successfully!
   You can now view frontend in the browser.
   
   Local: http://localhost:3000
   ```

3. **Browser Opens**
   - Should open to `http://localhost:3000`
   - Should show Home page with navbar
   - ✓ Frontend is running

### If It Fails

| Error | Solution |
|-------|----------|
| npm: command not found | Install Node.js from nodejs.org |
| Port 3000 in use | Kill process or change port in terminal |
| Compilation errors | Check console for error messages |
| White blank page | Press Ctrl+Shift+R to hard refresh |

---

## Test 4: Register Page Loads

### Objective
Verify Register page loads without errors.

### Steps

1. **In Browser**
   - URL: `http://localhost:3000`
   - Click "Register" in navbar

2. **Expected Display**
   ```
   Create your account
   
   [ Full name ]
   [ Email address ]
   [ Mobile number ]
   [ Username ]
   [ Password ]
   [ Confirm password ]
   [ Register button ]
   ```

3. **Check Browser Console (F12)**
   - Go to Console tab
   - Should have NO red error messages
   - Should show: "Compiled successfully!"
   - ✓ Page loaded without errors

### If It Fails

| Error | Solution |
|-------|----------|
| Page is blank/white | Hard refresh: Ctrl+Shift+R |
| Red errors in console | See specific error message |
| Form fields missing | Check browser rendering, try different browser |
| Can't navigate to Register | Click Register in navbar, not URL |

---

## Test 5: Registration Submission

### Objective
Test the full registration flow.

### Steps

1. **Fill Registration Form**
   ```
   Full Name:       Test User
   Email:           test@example.com
   Mobile:          1234567890
   Username:        testuser
   Password:        TestPass123
   Confirm Password: TestPass123
   ```

2. **Click Register**
   - Watch for response
   - Should see one of:
     - ✓ Success message (Redirects to Login)
     - ❌ Network Error (This is the problem we're fixing)
     - ❌ Validation Error (Wrong input)

3. **Check Browser Console (F12)**
   - Go to Network tab
   - Look for request: `auth/register`
   - Click it and check:
     - URL: `http://localhost:8080/api/auth/register`
     - Method: POST
     - Status: (200 = success, 400 = validation error, error = connection problem)
     - Response: Check what server returned

### Expected Network Request

```
POST http://localhost:8080/api/auth/register
Status: 200 or 400

Request Body:
{
  "fullName": "Test User",
  "email": "test@example.com",
  "mobile": "1234567890",
  "username": "testuser",
  "password": "TestPass123"
}

Response Body:
{
  "id": 1,
  "message": "User registered successfully"
}
```

### Troubleshooting Network Error

1. **Check Backend Terminal**
   - Look for error messages
   - Should show: `POST /api/auth/register`
   - Check if request was received

2. **Check API Response**
   - In Network tab, click the request
   - Click "Response" tab
   - What does it show?
   - Does it show JSON response or error?

3. **Verify Connectivity**
   ```bash
   # In new terminal:
   curl -X POST http://localhost:8080/api/auth/register ^
     -H "Content-Type: application/json" ^
     -d "{\"fullName\":\"Test\",\"email\":\"test@example.com\",\"username\":\"testuser\",\"password\":\"TestPass123\"}"
   ```

4. **Check API Configuration**
   - Verify: frontend/.env has correct URL
   - Verify: backend is running on port 8080
   - Verify: no firewall blocking port 8080

---

## Test 6: Database Verification

### Objective
Verify user was saved to database.

### Steps

1. **Check Backend Database**
   
   **Option A: H2 Console (if using H2)**
   ```
   1. Open: http://localhost:8080/h2-console
   2. Click: Connect
   3. Run SQL:
      SELECT * FROM USERS;
   ```

   **Option B: MySQL (if using MySQL)**
   ```bash
   mysql -u root -p fullstack_db
   mysql> SELECT * FROM USERS;
   ```

2. **Expected Result**
   ```
   ID | FULL_NAME  | EMAIL              | USERNAME  | PASSWORD                          | ROLE
   1  | Test User  | test@example.com   | testuser  | $2a$10$... (hashed password)      | USER
   ```

3. **Verify**
   - ☐ User ID exists
   - ☐ Full name is correct
   - ☐ Email is correct
   - ☐ Username is correct
   - ☐ Password is hashed (NOT plain text!)
   - ☐ Role is 'USER'

### If User Not Found

1. **Check Registration Response**
   - Did browser show success message?
   - Or did it show error?

2. **Check Backend Logs**
   - Look for error messages
   - Search for "register" or "save"

3. **Manual Test**
   ```bash
   # Test API directly:
   curl -X POST http://localhost:8080/api/auth/register ^
     -H "Content-Type: application/json" ^
     -d "{\"fullName\":\"Manual Test\",\"email\":\"manual@test.com\",\"username\":\"manual\",\"password\":\"ManualPass123\"}"
   
   # Check response for errors
   ```

---

## Test 7: Login Flow

### Objective
Verify login works with registered user.

### Steps

1. **Navigate to Login**
   - Click "Login" in navbar
   - Or manually: `http://localhost:3000/login`

2. **Enter Credentials**
   ```
   Username: testuser
   Password: TestPass123
   ```

3. **Click Login**
   - Should authenticate
   - Should redirect to Dashboard

4. **Check Dashboard**
   - Should show: "Welcome back, testuser"
   - Should have Logout button
   - ✓ Login successful

5. **Check localStorage (F12)**
   - Open DevTools: F12
   - Go to: Application → Storage → Local Storage → localhost:3000
   - Should see:
     - `token`: (long JWT string)
     - `user`: (JSON object with user data)
     - `username`: testuser
   - ✓ Token stored correctly

### Troubleshooting Login Issues

| Error | Solution |
|-------|----------|
| "Invalid credentials" | Check username/password match database |
| No token in localStorage | Login didn't complete. Check console |
| Can't see Dashboard | May need to hard refresh browser |
| Still on Login page | Check backend logs for auth errors |

---

## Test 8: Protected Routes

### Objective
Verify protected routes require authentication.

### Steps

1. **Close Browser (Or Clear localStorage)**
   ```bash
   # Clear localStorage:
   # Open F12 → Console → type:
   localStorage.clear()
   ```

2. **Try Accessing Dashboard**
   - URL: `http://localhost:3000/dashboard`
   - Should REDIRECT to login
   - Should NOT show dashboard content
   - ✓ Route is protected

3. **Try Accessing Profile**
   - URL: `http://localhost:3000/profile`
   - Should REDIRECT to login
   - Should NOT show users table
   - ✓ Route is protected

### Expected Behavior

```
Unauthenticated User
    ↓
Tries: http://localhost:3000/dashboard
    ↓
ProtectedRoute component checks localStorage
    ↓
No token found
    ↓
Redirect to: http://localhost:3000/login
    ↓
User sees Login page
```

---

## Test 9: Logout Flow

### Objective
Verify logout works completely.

### Steps

1. **Login First** (if not already logged in)
   - Username: testuser
   - Password: TestPass123

2. **Check localStorage Before Logout**
   - F12 → Application → Local Storage
   - Should have: token, user, username
   - ✓ Logged in

3. **Click Logout Button**
   - On Dashboard page
   - Click "Logout" button

4. **Verify Redirect**
   - Should redirect to Login page
   - URL should be: `http://localhost:3000/login`
   - ✓ Redirected immediately

5. **Check localStorage After Logout**
   - F12 → Application → Local Storage
   - Should be EMPTY
   - No token, user, or username
   - ✓ Session cleared

6. **Test Back Button**
   - Press browser Back button
   - Should NOT go back to Dashboard
   - Should stay on Login page
   - ✓ Back button prevented

7. **Try Accessing Dashboard**
   - Manually enter: `http://localhost:3000/dashboard`
   - Should redirect to Login page
   - Should NOT show Dashboard
   - ✓ Still protected after logout

### Expected Logout Behavior

```
User clicks Logout
    ↓
authService.logout() called
    ↓
Clear all localStorage
    ↓
navigate('/login', { replace: true })
    ↓
Redirect to Login page
    ↓
History entry replaced (back button prevented)
    ↓
User must login again to access Dashboard
```

---

## Complete Test Checklist

Copy and use this checklist:

```
BACKEND
☐ Java installed: java -version shows version
☐ Maven available: mvn -version works
☐ Backend starts: mvn spring-boot:run shows "Tomcat started"
☐ API responds: curl http://localhost:8080/api/users returns 200

FRONTEND
☐ Node.js installed: node --version shows version
☐ npm installed: npm --version shows version
☐ .env exists: type frontend\.env shows config
☐ Dependencies installed: frontend/node_modules exists
☐ Frontend starts: npm start shows "Compiled successfully"
☐ Browser opens: localhost:3000 shows Home page

REGISTRATION
☐ Register page loads: No errors in console
☐ Form submits: No "Network Error"
☐ Correct API endpoint: Network tab shows /auth/register
☐ Backend receives request: Backend terminal shows POST request
☐ Backend returns 200: Network tab shows status 200
☐ Response has user data: Network tab shows {id, message}
☐ User saved to database: SELECT * FROM USERS shows new user
☐ Password is hashed: Password starts with $2a$ not plain text

LOGIN
☐ Login page loads: No errors
☐ Can enter credentials: Form works
☐ Backend authenticates: Returns 200
☐ Token returned: Response has "token" field
☐ Token stored: localStorage has "token" key
☐ Redirects to Dashboard: URL becomes /dashboard
☐ Dashboard displays: Shows "Welcome back, testuser"
☐ Shows username: Dashboard displays correct username

PROTECTED ROUTES
☐ Clear localStorage: localStorage.clear() works
☐ Can't access /dashboard: Redirects to /login
☐ Can't access /profile: Redirects to /login
☐ Can't access with invalid token: Redirects to /login

LOGOUT
☐ Logout button visible: On Dashboard page
☐ Click logout: Redirects immediately
☐ localStorage cleared: No token, user, username
☐ Back button prevented: Can't go back to Dashboard
☐ Accessing Dashboard redirects: Must login again
☐ Session ended: No token in browser storage

DATABASE
☐ Table created: SELECT * FROM USERS works
☐ User saved: See test@example.com in table
☐ All fields correct: fullName, email, username, role
☐ Duplicate prevention: Can't register same username twice
```

---

## Common Test Failures & Solutions

### Failure: "Network Error" on Register

**Root Cause:** Backend not running or not responding

**Solution:**
```bash
1. Check if backend is running:
   curl http://localhost:8080/api/users
   
2. If connection refused:
   cd backend
   mvn spring-boot:run
   
3. Wait for "Tomcat started on port 8080"
```

### Failure: "Invalid credentials" on Login

**Root Cause:** User not saved or wrong password

**Solution:**
```bash
1. Check database:
   SELECT * FROM USERS WHERE username='testuser';
   
2. If empty, re-register:
   - Go back to Register page
   - Fill form again
   - Check database after registration
   
3. Verify password:
   - Must be exactly: TestPass123
   - Check for typos
```

### Failure: Dashboard accessible without login

**Root Cause:** ProtectedRoute not working

**Solution:**
```bash
1. Check frontend/src/components/ProtectedRoute.js exists
2. Check App.js wraps dashboard route:
   <Route path="/dashboard" 
     element={<ProtectedRoute><Dashboard/></ProtectedRoute>}/>
3. Clear browser cache: Ctrl+Shift+Delete
4. Hard refresh: Ctrl+Shift+R
```

### Failure: Logout doesn't clear data

**Root Cause:** localStorage not cleared

**Solution:**
```bash
1. Check browser console:
   localStorage.clear()
   
2. Check that logout button calls authService.logout()
3. Verify all keys removed: localStorage
   Should show: Storage {}
```

---

## Next Steps After Tests Pass

Once all tests pass:

1. **Review Code Changes**
   - frontend/src/services/api.js
   - frontend/src/services/authService.js
   - backend/src/main/java/com/example/backend/controller/AuthController.java

2. **Test With Real MySQL** (Optional)
   - Edit application.properties
   - Set environment variables for MySQL
   - Re-register and login
   - Verify same flow works

3. **Deploy to Production** (When ready)
   - Use production database
   - Change jwt.secret
   - Configure proper CORS origins
   - Use HTTPS

4. **Monitor Application**
   - Check backend logs regularly
   - Monitor database growth
   - Set up error tracking

---

## Getting Help

If tests still fail:

1. **Check Documentation**
   - FIX_NETWORK_ERROR.md
   - COMPLETE_FIX_SUMMARY.md
   - QUICK_START.md

2. **Run Diagnostic Script**
   ```bash
   .\DIAGNOSE.ps1
   ```

3. **Check Logs**
   - Backend terminal: Look for ERROR or WARN
   - Browser console (F12): Check for JavaScript errors
   - Browser Network tab: Check request/response

4. **Manual API Test**
   ```bash
   # Register test
   curl -X POST http://localhost:8080/api/auth/register \
     -H "Content-Type: application/json" \
     -d "{...user data...}"
   
   # Login test
   curl -X POST http://localhost:8080/api/auth/login \
     -H "Content-Type: application/json" \
     -d "{\"username\":\"testuser\",\"password\":\"TestPass123\"}"
   ```

---

Good luck! You've got this! 🚀
