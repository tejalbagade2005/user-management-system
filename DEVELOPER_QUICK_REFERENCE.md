# Developer Quick Reference

## File Locations & Changes

### Frontend Changes

| File | Path | What Changed |
|------|------|--------------|
| authService.js | `frontend/src/services/` | Added helper methods (isLoggedIn, clearAuth, etc) |
| api.js | `frontend/src/services/` | Added 401 response interceptor |
| App.js | `frontend/src/` | Added ProtectedRoute wrapper |
| Login.js | `frontend/src/pages/` | Rewritten with navigate() and error handling |
| Register.js | `frontend/src/pages/` | Rewritten with navigate() and error handling |
| Dashboard.js | `frontend/src/pages/` | Rewritten logout with navigate() |
| Profile.js | `frontend/src/pages/` | Added auth check in useEffect |
| ProtectedRoute.js | `frontend/src/components/` | NEW - Route protection component |

### Backend Changes

| File | Path | What Changed |
|------|------|--------------|
| AuthController.java | `backend/src/main/java/com/example/backend/controller/` | Returns user object with token; better error handling |
| SecurityConfig.java | `backend/src/main/java/com/example/backend/security/` | Fixed authorization rules |

---

## Code Snippets

### Protecting a Route in App.js
```javascript
<Route path="/dashboard" element={<ProtectedRoute><Dashboard/></ProtectedRoute>} />
```

### Checking Authentication in Component
```javascript
import authService from '../services/authService';

useEffect(() => {
  if (!authService.isLoggedIn()) {
    navigate('/login', { replace: true });
  }
}, [navigate]);
```

### Logging Out Properly
```javascript
const handleLogout = useCallback(async () => {
  try {
    await authService.logout();
  } catch (err) {
    console.error('Logout error:', err);
  } finally {
    authService.clearAuth();
    navigate('/login', { replace: true });
  }
}, [navigate]);
```

### Redirecting After Login
```javascript
navigate('/dashboard', { replace: true });
```

### Getting Stored User Data
```javascript
const user = JSON.parse(localStorage.getItem('user'));
const username = user.username;
```

### Making Authenticated API Call
```javascript
// Token is automatically added by api.js interceptor
const response = await api.get('/users');
```

---

## Common Tasks

### Add a New Protected Route

**Step 1:** Create component in `frontend/src/pages/`
```javascript
import { useNavigate } from 'react-router-dom';
import authService from '../services/authService';

export default function MyPage() {
  const navigate = useNavigate();
  
  useEffect(() => {
    if (!authService.isLoggedIn()) {
      navigate('/login', { replace: true });
    }
  }, [navigate]);
  
  return <div>Protected Content</div>;
}
```

**Step 2:** Add to App.js
```javascript
<Route path="/mypage" element={<ProtectedRoute><MyPage/></ProtectedRoute>} />
```

### Make an Authenticated API Call

**Option 1:** Simple GET
```javascript
const response = await api.get('/api/users');
const users = response.data;
```

**Option 2:** With Error Handling
```javascript
try {
  const response = await api.get('/api/users');
  setUsers(response.data);
} catch (err) {
  if (err.response?.status === 401) {
    // User is logged out - handled by interceptor
  } else {
    setError(err.response?.data?.error || 'Request failed');
  }
}
```

**Option 3:** POST with Data
```javascript
try {
  const response = await api.post('/api/auth/register', {
    fullName: 'John Doe',
    email: 'john@example.com',
    username: 'johndoe',
    password: 'Password123'
  });
  // Handle success
} catch (err) {
  setError(err.response?.data?.error || 'Request failed');
}
```

### Handle Logout
```javascript
import authService from '../services/authService';

const logout = async () => {
  try {
    await authService.logout();
  } catch (err) {
    console.error('Logout error:', err);
  } finally {
    authService.clearAuth();
    navigate('/login', { replace: true });
  }
};
```

### Check User Authentication
```javascript
if (authService.isLoggedIn()) {
  // User is logged in
  const token = authService.getStoredToken();
  const user = authService.getStoredUser();
} else {
  // User is not logged in
}
```

---

## Debugging Tips

### 1. Check localStorage
```javascript
// In browser console
console.log(localStorage);
console.log(localStorage.getItem('token'));
console.log(JSON.parse(localStorage.getItem('user')));
```

### 2. Check JWT Token Content
```javascript
// Decode JWT (if it's valid)
const token = localStorage.getItem('token');
const payload = JSON.parse(atob(token.split('.')[1]));
console.log(payload);  // Shows username, exp, iat
```

### 3. Monitor API Calls
```javascript
// Open DevTools → Network tab
// Filter by XHR to see API calls
// Click each request to see:
// - Request headers (Authorization: Bearer...)
// - Response status (200, 401, etc)
// - Response body (JSON)
```

### 4. Check React Router Navigation
```javascript
// In any component
import { useLocation } from 'react-router-dom';

const location = useLocation();
console.log('Current path:', location.pathname);
```

### 5. Monitor useEffect Execution
```javascript
useEffect(() => {
  console.log('Component mounted, checking auth');
  if (!authService.isLoggedIn()) {
    console.log('No token, redirecting to login');
    navigate('/login', { replace: true });
  }
}, [navigate]);
```

### 6. Check Backend Logs
```bash
# Backend logs will show:
# - Authentication attempts
# - Token generation
# - Validation errors
# - Database operations
```

### 7. View Database Directly
```sql
mysql> SELECT * FROM users;
mysql> SELECT username, email FROM users WHERE username='testuser';
mysql> SELECT COUNT(*) FROM users;
```

---

## Error Handling

### Common Error Responses

**400 Bad Request**
```json
{
  "error": "Username already exists"
}
```

**401 Unauthorized**
```json
{
  "error": "Invalid credentials"
}
```

**404 Not Found**
```json
{
  "error": "User not found"
}
```

**500 Server Error**
```json
{
  "error": "Internal server error"
}
```

### Handling in Frontend
```javascript
try {
  await api.post('/auth/login', credentials);
} catch (err) {
  if (err.response?.status === 400) {
    // Bad request - show error message
    setError(err.response.data.error);
  } else if (err.response?.status === 401) {
    // Unauthorized - interceptor handles
  } else if (err.response?.status === 500) {
    // Server error
    setError('Server error, please try again later');
  } else {
    // Network error
    setError('Network error, please check your connection');
  }
}
```

---

## Performance Optimization

### 1. Use useCallback for Event Handlers
```javascript
const handleLogout = useCallback(async () => {
  // Prevents function from being recreated on every render
  // Dependency array specifies when to recreate
}, [navigate]);
```

### 2. Use useEffect for Data Fetching
```javascript
useEffect(() => {
  let mounted = true;
  
  const fetchData = async () => {
    try {
      const response = await api.get('/users');
      if (mounted) {
        setUsers(response.data);
      }
    } catch (err) {
      if (mounted) {
        setError(err.message);
      }
    }
  };
  
  fetchData();
  
  // Cleanup on unmount
  return () => { mounted = false; };
}, []);
```

### 3. Avoid Unnecessary Re-renders
```javascript
// Bad - creates new object every render
<ProtectedRoute>
  <Component config={{}} />
</ProtectedRoute>

// Good - define outside component
const config = {};
<ProtectedRoute>
  <Component config={config} />
</ProtectedRoute>
```

---

## Testing Command Snippets

### Test Registration via cURL
```bash
curl -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Test User",
    "email": "test@example.com",
    "username": "testuser",
    "password": "TestPass123",
    "mobile": "1234567890"
  }'
```

### Test Login via cURL
```bash
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "TestPass123"
  }'
```

### Extract Token and Use It
```bash
# Get token
TOKEN=$(curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"TestPass123"}' \
  | jq -r '.token')

# Use token
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8080/api/users
```

### Test Protected Endpoint Without Token
```bash
# Should return 401
curl http://localhost:8080/api/users/1/update

# Should return 200
curl -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  http://localhost:8080/api/users/1/update
```

---

## Configuration Quick Edit

### Change JWT Expiration
File: `backend/src/main/resources/application.properties`
```properties
# Before (24 hours)
jwt.expiration=86400000

# After (30 minutes)
jwt.expiration=1800000
```

### Change Frontend API URL
File: `frontend/.env`
```
# Development
REACT_APP_API_URL=http://localhost:8080/api

# Production
REACT_APP_API_URL=https://api.example.com/api
```

### Change CORS Origin
File: `backend/src/main/java/com/example/backend/security/SecurityConfig.java`
```java
// Before
configuration.addAllowedOrigin("http://localhost:3000");

// After (production)
configuration.addAllowedOrigin("https://example.com");
```

---

## Useful Git Commands

```bash
# See what changed
git diff

# See specific file changes
git diff frontend/src/pages/Login.js

# View commit history
git log --oneline

# Check current branch
git branch

# Create backup branch before making changes
git checkout -b backup-auth-fix

# Switch back to main
git checkout main
```

---

## npm/Maven Commands

### Frontend
```bash
# Install dependencies
npm install

# Start development server
npm start

# Build for production
npm run build

# Run tests
npm test

# Clear node_modules cache
npm cache clean --force
```

### Backend
```bash
# Clean and install
mvn clean install

# Run spring boot
mvn spring-boot:run

# Run tests
mvn test

# Build without tests
mvn clean install -DskipTests

# View dependency tree
mvn dependency:tree
```

---

## Key Concepts

### JWT Token Structure
```
Header.Payload.Signature

Example:
eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ0ZXN0dXNlciIsImlhdCI6MTY4ODAxNDAwMCwiZXhwIjoxNjg4MTAwNDAwfQ.signature
```

### React Router Navigation
```javascript
import { useNavigate } from 'react-router-dom';

const navigate = useNavigate();

// Navigate to path, adds to history (back button works)
navigate('/dashboard');

// Navigate to path, replaces current history (back button doesn't work)
navigate('/login', { replace: true });
```

### localStorage vs sessionStorage
```javascript
// localStorage - persists until manually cleared
localStorage.setItem('token', 'value');
localStorage.getItem('token');
localStorage.removeItem('token');
localStorage.clear();

// sessionStorage - cleared when tab closes
sessionStorage.setItem('key', 'value');
sessionStorage.getItem('key');
sessionStorage.removeItem('key');
sessionStorage.clear();
```

### HTTP Status Codes
- 200 OK - Success
- 201 Created - Resource created
- 400 Bad Request - Client error, bad data
- 401 Unauthorized - No valid token/credentials
- 403 Forbidden - Valid token but no permission
- 404 Not Found - Resource doesn't exist
- 500 Internal Server Error - Server error

---

## Resources

- React Router: https://reactrouter.com/
- Axios: https://axios-http.com/
- Spring Security: https://spring.io/projects/spring-security
- JWT: https://jwt.io/
- MySQL: https://dev.mysql.com/
- Maven: https://maven.apache.org/

---

## Quick Checklist for New Developer

- [ ] Understand the authentication flow (see COMPLETE_FIX_SUMMARY.md)
- [ ] Know where ProtectedRoute is used (App.js)
- [ ] Know how authService works (frontend/src/services/authService.js)
- [ ] Know how api.js interceptors work (frontend/src/services/api.js)
- [ ] Know what JWT is and how it's used
- [ ] Know how to check browser localStorage (DevTools → Application)
- [ ] Know how to read backend logs
- [ ] Know how to test API endpoints (curl or Postman)
- [ ] Understand security layers (4 layers explained in COMPLETE_FIX_SUMMARY.md)
- [ ] Know how to debug (see Debugging Tips section)

---

## Need Help?

1. Check **COMPLETE_FIX_SUMMARY.md** for full explanation
2. Check **AUTH_FIX_DOCUMENTATION.md** for detailed technical info
3. Check **QUICK_START.md** for setup issues
4. Check **TESTING_GUIDE.md** for test issues
5. Check browser DevTools Console/Network tabs
6. Check backend logs in terminal
7. Check MySQL database with sql queries
