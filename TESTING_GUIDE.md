# Testing Guide - Complete Verification

This guide will help you verify that all authentication features work correctly.

## Prerequisites
- Backend running on http://localhost:8080
- Frontend running on http://localhost:3000
- MySQL database connected

## Test 1: User Registration

### Steps
1. Navigate to http://localhost:3000/register
2. Fill in the registration form:
   - Full Name: Test User
   - Email: testuser@example.com
   - Mobile: 9876543210
   - Username: testuser
   - Password: TestPass123
   - Confirm Password: TestPass123
3. Click the Register button

### Expected Results
✅ Should see success message
✅ Should redirect to /login
✅ Back button should NOT work (history is cleared)
✅ User should be saved in MySQL database

### Verification (MySQL)
```sql
SELECT * FROM users WHERE username='testuser';
-- Should show the newly created user with encrypted password
```

### Test Duplicate Registration
1. Try to register with same username/email
2. Should see error: "Username already exists" or "Email already exists"

---

## Test 2: User Login

### Steps
1. At login page, enter credentials:
   - Username: testuser
   - Password: TestPass123
2. Click Login button

### Expected Results
✅ Should redirect to /dashboard
✅ Dashboard should show "Welcome back, testuser"
✅ localStorage should contain:
   - token: (JWT token)
   - user: (JSON with user details)
   - username: testuser

### Verification (Browser DevTools)
```javascript
// In browser console
console.log(localStorage.getItem('token'));
console.log(JSON.parse(localStorage.getItem('user')));
```

### Test Login with Email
1. Try logging in with email instead of username
2. Should work the same way

### Test Invalid Credentials
1. Enter wrong password
2. Should see error: "Invalid credentials"
3. Should NOT redirect
4. Should stay on login page

---

## Test 3: Dashboard Access

### Steps
1. After successful login, verify you're on dashboard
2. Click Dashboard in navbar

### Expected Results
✅ Should show user's username
✅ Should show dashboard content
✅ Logout button should be visible
✅ Can click on Profile link in navbar

### Test Protected Route Access
1. Open new tab and go to http://localhost:3000/dashboard
2. Should work (you're already logged in)

### Test Unprotected Dashboard Access
1. Open new private/incognito window
2. Go to http://localhost:3000/dashboard
3. Should redirect to /login
4. Should NOT show dashboard content

---

## Test 4: Profile Page

### Steps
1. From Dashboard, click Profile
2. Should see list of all users in database
3. Newly registered user should be in the list

### Expected Results
✅ Should load without errors
✅ Should show table with columns: ID, Full Name, Username, Email, Mobile
✅ Should show at least the registered test user

### Test Protected Profile Access
1. Open new private/incognito window
2. Go to http://localhost:3000/profile
3. Should redirect to /login

---

## Test 5: Logout Functionality

### Steps
1. From Dashboard, click Logout button
2. Observe what happens

### Expected Results
✅ Should redirect to /login immediately
✅ localStorage should be completely empty
✅ Back button should NOT work (can't go back to dashboard)
✅ Trying to access /dashboard should redirect to /login again

### Verification
1. After logout, check localStorage (should be empty):
```javascript
console.log(localStorage);
// Should show: Storage { length: 0 }
```

2. Try accessing /dashboard:
- Type in URL: http://localhost:3000/dashboard
- Should redirect to /login
- Should NOT show dashboard content

---

## Test 6: Back Button Prevention

### Steps
1. Login to the application
2. Click Dashboard
3. Click Logout
4. Immediately after redirect to login, press Back button

### Expected Results
✅ Back button should NOT work
✅ Should stay on /login page
✅ Should NOT show dashboard

### Why This Works
- `navigate('/login', { replace: true })` replaces the history entry
- So there's nothing to go back to

---

## Test 7: Token Expiration

### Optional: Test with Short Expiration
1. Edit `backend/src/main/resources/application.properties`:
   ```properties
   jwt.expiration=60000  # 1 minute instead of 1 day
   ```
2. Restart backend
3. Login to application
4. Wait 1 minute
5. Try to access Profile page

### Expected Results
✅ API should return 401 (Unauthorized)
✅ Frontend should clear localStorage
✅ Frontend should redirect to /login
✅ You'll be logged out automatically

---

## Test 8: Multiple Users

### Register Another User
1. Open new private/incognito window
2. Register with different credentials:
   - Full Name: Another User
   - Email: another@example.com
   - Username: anotheruser
   - Password: AnotherPass123

### Login as Different User
1. Login with anotheruser credentials
2. Dashboard should show "Welcome back, anotheruser"
3. Profile should show both users in the table

### Test Simultaneous Sessions
1. Open two browser windows
2. Login as testuser in window 1
3. Login as anotheruser in window 2
4. Each should show their respective username
5. Logout in one window
6. Other window should still be logged in (independent sessions)

---

## Test 9: API Endpoints

### Test Public Endpoints (No Auth Required)

```bash
# Get all users (public)
curl http://localhost:8080/api/users

# Get specific user (public)
curl http://localhost:8080/api/users/1
```

### Test Protected Endpoints (Auth Required)

```bash
# First, login and get token
TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"TestPass123"}' \
  | jq -r '.token')

# Update user (requires token)
curl -X PUT http://localhost:8080/api/users/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"fullName":"Updated Name","email":"testuser@example.com","username":"testuser"}'

# Delete user (requires token)
curl -X DELETE http://localhost:8080/api/users/1 \
  -H "Authorization: Bearer $TOKEN"
```

### Test Invalid Token
```bash
# Try with invalid token
curl http://localhost:8080/api/users/1/update \
  -H "Authorization: Bearer invalid_token"
# Should get 401 error
```

---

## Test 10: Error Handling

### Registration Errors
- [ ] Empty fields show validation error
- [ ] Invalid email format shows error
- [ ] Password too short shows error
- [ ] Passwords don't match shows error
- [ ] Duplicate username shows specific error
- [ ] Duplicate email shows specific error

### Login Errors
- [ ] Wrong password shows specific error
- [ ] Non-existent user shows error
- [ ] Empty username/password shows error
- [ ] Error message is NOT generic "Login failed"

### API Errors
- [ ] Network errors are handled gracefully
- [ ] 401 errors redirect to login
- [ ] 404 errors are handled
- [ ] Server errors are logged

---

## Complete Test Checklist

Copy this checklist and mark off each test:

```
REGISTRATION TESTS
- [ ] New user registration succeeds
- [ ] User saved to database with encrypted password
- [ ] Duplicate username error shown
- [ ] Duplicate email error shown
- [ ] Redirect to login after registration
- [ ] Back button doesn't work after registration

LOGIN TESTS
- [ ] Login with username succeeds
- [ ] Login with email succeeds
- [ ] Invalid password shows error
- [ ] Non-existent user shows error
- [ ] Redirect to dashboard after login
- [ ] Token stored in localStorage
- [ ] User object stored in localStorage
- [ ] Back button doesn't work after login

AUTHENTICATION TESTS
- [ ] Dashboard accessible when logged in
- [ ] Profile accessible when logged in
- [ ] Dashboard shows username
- [ ] Profile shows all users
- [ ] Can access /dashboard from URL when logged in
- [ ] Can access /profile from URL when logged in

PROTECTION TESTS
- [ ] Unauthenticated user redirected from /dashboard
- [ ] Unauthenticated user redirected from /profile
- [ ] Private window can't access /dashboard
- [ ] Private window can't access /profile
- [ ] localStorage is empty in private window
- [ ] Redirects happen before content renders

LOGOUT TESTS
- [ ] Logout button works
- [ ] Redirect to /login after logout
- [ ] localStorage is empty after logout
- [ ] sessionStorage is empty after logout
- [ ] Back button doesn't show dashboard
- [ ] Can't access /dashboard after logout
- [ ] Can't access /profile after logout
- [ ] Re-login works after logout

TOKEN TESTS
- [ ] Token is in correct JWT format
- [ ] Token decoding shows username in payload
- [ ] Expired token triggers logout
- [ ] API interceptor handles 401 response
- [ ] Automatic redirect to login on 401

MULTI-USER TESTS
- [ ] Register multiple users
- [ ] Each user sees their own data
- [ ] Profile shows all users
- [ ] Logout one user, others still logged in
- [ ] Each user has independent session

ERROR MESSAGE TESTS
- [ ] Registration errors are specific
- [ ] Login errors are specific
- [ ] No generic "failed" messages
- [ ] Error messages are user-friendly

DATABASE TESTS
- [ ] Users table exists
- [ ] Users are created with all fields
- [ ] Passwords are hashed (not plain text)
- [ ] Unique constraints on username and email
```

---

## Performance Tests (Optional)

### Load Test
1. Create 100 users
2. Login and access Profile
3. Should load users table without lag

### Stress Test
1. Rapid login/logout cycles
2. Should handle without errors
3. localStorage should be consistent

---

## Security Tests (Optional)

### SQL Injection
1. Try username: `admin' OR '1'='1`
2. Should fail with "Invalid credentials"
3. Should NOT bypass login

### XSS Prevention
1. Register with name: `<script>alert('xss')</script>`
2. Should be escaped and displayed as text
3. Should NOT execute script

### CSRF Prevention
1. CSRF tokens should be handled by framework
2. Cross-origin requests should fail
3. Same-origin requests should work

---

## Browser Console Monitoring

While testing, keep DevTools open to check for:

1. **Console Tab**
   - Should have NO errors
   - Should have NO warnings related to auth

2. **Network Tab**
   - Login request should return 200
   - Logout request should return 200
   - Protected endpoints should return 200 with token
   - Protected endpoints should return 401 without token

3. **Application Tab**
   - localStorage should have token, user, username when logged in
   - localStorage should be empty when logged out

4. **Performance Tab**
   - Page loads should be quick
   - No memory leaks

---

## Final Verification

When all tests pass, your application is:
✅ Secure - Protected routes are enforced
✅ Functional - All features work as expected
✅ User-friendly - Clear error messages
✅ Reliable - Consistent state management
✅ Production-ready - Multiple layers of protection

---

## Getting Help

If any test fails:

1. **Check Backend Logs**
   - Look for errors in terminal where backend is running
   - Check for Spring Security errors
   - Look for database connection errors

2. **Check Frontend Logs**
   - Open Browser DevTools (F12)
   - Console tab for errors
   - Network tab for API response details
   - Application tab to see localStorage

3. **Check Database**
   ```sql
   SELECT * FROM users;
   SHOW CREATE TABLE users;
   ```

4. **Restart Services**
   - Kill and restart backend
   - Kill and restart frontend
   - Clear browser cache (Ctrl+Shift+Delete)

5. **Check Configuration**
   - application.properties (backend)
   - .env (frontend)
   - CORS settings in SecurityConfig
