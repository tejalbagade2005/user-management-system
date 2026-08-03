# Architecture & Flow Diagrams

## 1. Complete Authentication Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                   REGISTRATION FLOW                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  User                 React                  Spring Boot          │
│  ─────────────────────────────────────────────────────────────   │
│    │                   │                        │                │
│    │ Fills Form        │                        │                │
│    ├──────────────────>│ Validate              │                │
│    │                   ├─ Check format         │                │
│    │                   ├─ Check passwords     │                │
│    │                   │                        │                │
│    │                   │ POST /auth/register   │                │
│    │                   │─────────────────────>│                │
│    │                   │                   ├─ Check username   │
│    │                   │                   ├─ Check email      │
│    │                   │                   ├─ Hash password    │
│    │                   │                   ├─ Save to MySQL    │
│    │                   │                   │                    │
│    │                   │<─────────────────┤                     │
│    │                   │ 200 OK {id, msg}  │                    │
│    │                   │                    │                    │
│    │ Redirected to    │                    │                    │
│    │ Login            │<──────────────────┤                    │
│    │ (replace:true)   │ navigate()        │                    │
│    │                   │                    │                    │
│
└─────────────────────────────────────────────────────────────────┘
```

## 2. Login Flow with Token Storage

```
┌─────────────────────────────────────────────────────────────────┐
│                      LOGIN FLOW                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  User              React                Spring Boot              │
│  ────────────────────────────────────────────────────────────   │
│    │                 │                      │                   │
│    │ Login Creds     │                      │                   │
│    ├────────────────>│ POST /auth/login     │                   │
│    │                 │─────────────────────>│                   │
│    │                 │                  ├─ Authenticate        │
│    │                 │                  ├─ Generate JWT        │
│    │                 │                  ├─ Fetch user data     │
│    │                 │                  │                       │
│    │                 │<─────────────────┤                       │
│    │                 │ 200 OK             │                     │
│    │                 │ {token, user}      │                     │
│    │                 │                      │                     │
│    │                 │ localStorage.setItem('token', token)     │
│    │                 │ localStorage.setItem('user', user)       │
│    │                 │ localStorage.setItem('username', username)
│    │                 │                      │                     │
│    │                 │ navigate('/dashboard', {replace:true})   │
│    │                 │                      │                     │
│    │ Redirected to   │                      │                     │
│    │ Dashboard       │                      │                     │
│    │                 │                      │                     │
│
└─────────────────────────────────────────────────────────────────┘
```

## 3. Protected Route Access

```
┌─────────────────────────────────────────────────────────────────┐
│              PROTECTED ROUTE (Dashboard/Profile)                  │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Browser Request                                                  │
│    │                                                              │
│    ├─ /dashboard                                                │
│    │                                                              │
│    ▼                                                              │
│  ┌─────────────────────────────────────────────────┐            │
│  │ App.js                                          │            │
│  │ <Route path="/dashboard"                        │            │
│  │   element={<ProtectedRoute>                     │            │
│  │     <Dashboard/>                                │            │
│  │   </ProtectedRoute>}                            │            │
│  └─────────────────────────────────────────────────┘            │
│    │                                                              │
│    ▼                                                              │
│  ┌─────────────────────────────────────────────────┐            │
│  │ ProtectedRoute Component                        │            │
│  │ Check: token = localStorage.getItem('token')   │            │
│  └─────────────────────────────────────────────────┘            │
│    │                                                              │
│    ├─ Token found? ─────────────────> Render Dashboard         │
│    │                                                              │
│    └─ No token? ───────────────────> <Navigate to="/login"/>   │
│                                                                   │
│  ┌─────────────────────────────────────────────────┐            │
│  │ Dashboard Component (if rendered)               │            │
│  │ useEffect(() => {                               │            │
│  │   if (!authService.isLoggedIn())                │            │
│  │     navigate('/login', {replace: true})         │            │
│  │ })                                              │            │
│  └─────────────────────────────────────────────────┘            │
│                                                                   │
│  Double-check: Component also verifies auth                      │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 4. Logout Flow with Session Cleanup

```
┌─────────────────────────────────────────────────────────────────┐
│                     LOGOUT FLOW                                   │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Dashboard         React                Spring Boot              │
│  ───────────────────────────────────────────────────────────── │
│    │                 │                      │                   │
│    │ Click Logout    │                      │                   │
│    ├────────────────>│ handleLogout()       │                   │
│    │                 │ ├─ try {            │                   │
│    │                 │ │  POST /auth/logout│                   │
│    │                 │ ├─────────────────>│                   │
│    │                 │ │                   │ (Log out user)    │
│    │                 │ │<─────────────────┤                   │
│    │                 │ │  200 OK          │                   │
│    │                 │ └ finally {        │                   │
│    │                 │                      │                   │
│    │                 │ clearAuth()         │                   │
│    │                 │ ├─ localStorage.removeItem('token')     │
│    │                 │ ├─ localStorage.removeItem('user')      │
│    │                 │ ├─ localStorage.removeItem('username')  │
│    │                 │ └─ sessionStorage.clear()               │
│    │                 │                      │                   │
│    │                 │ navigate('/login', {replace:true})      │
│    │                 │                      │                   │
│    │ Redirected to   │                      │                   │
│    │ Login Page      │                      │                   │
│    │ (Back doesn't   │                      │                   │
│    │  work anymore)  │                      │                   │
│    │                 │                      │                   │
│
└─────────────────────────────────────────────────────────────────┘
```

## 5. API Request with Token (Interceptor)

```
┌─────────────────────────────────────────────────────────────────┐
│                  API REQUEST WITH TOKEN                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  React Component                   api.js Interceptor           │
│  ───────────────────────────────────────────────────────        │
│    │                                  │                         │
│    │ api.get('/users')                │                        │
│    ├─────────────────────────────────>│                        │
│    │                                   │ Request Interceptor:  │
│    │                                   ├─ token = localStorage.getItem('token')
│    │                                   ├─ config.headers.Authorization = `Bearer ${token}`
│    │                                   │                        │
│    │                                   │ POST http://localhost:8080/api/users
│    │                                   │ Header: Authorization: Bearer eyJhbGc...
│    │                                   │                        │
│    │                                   ├──────────────────────>│
│    │                                   │                   Spring Boot
│    │                                   │                   ├─ Validate JWT
│    │                                   │                   ├─ Check expiration
│    │                                   │                   ├─ Set user context
│    │                                   │                   │
│    │                                   │<──────────────────┤
│    │                                   │ 200 OK [users]    │
│    │                                   │                    │
│    │<─────────────────────────────────┤                    │
│    │ response.data = [users]          │                    │
│    │                                   │                    │
│    │ OR                                │                    │
│    │                                   │<──────────────────┤
│    │                                   │ 401 Unauthorized  │
│    │                                   │                    │
│    │                                   │ Response Interceptor:
│    │                                   ├─ localStorage.clear()
│    │                                   ├─ navigate('/login')
│    │                                   │
│    │ (Redirected to login)            │
│    │                                   │
│
└─────────────────────────────────────────────────────────────────┘
```

## 6. Security Architecture (Multiple Layers)

```
┌───────────────────────────────────────────────────────────┐
│          SECURITY LAYERS (Defense in Depth)               │
├───────────────────────────────────────────────────────────┤
│                                                            │
│  LAYER 1: ProtectedRoute Component (Frontend)            │
│  ┌──────────────────────────────────────────────────┐   │
│  │ <Route path="/dashboard"                         │   │
│  │   element={<ProtectedRoute>                      │   │
│  │     <Dashboard/>                                 │   │
│  │   </ProtectedRoute>}                             │   │
│  │                                                   │   │
│  │ Check: if (!token) → Redirect to /login          │   │
│  └──────────────────────────────────────────────────┘   │
│                          ▼                                 │
│                                                            │
│  LAYER 2: Component useEffect (Frontend)                 │
│  ┌──────────────────────────────────────────────────┐   │
│  │ useEffect(() => {                                │   │
│  │   if (!authService.isLoggedIn())                 │   │
│  │     navigate('/login', {replace:true})           │   │
│  │ }, [navigate])                                    │   │
│  │                                                   │   │
│  │ Check: Double-verify token in component          │   │
│  └──────────────────────────────────────────────────┘   │
│                          ▼                                 │
│                                                            │
│  LAYER 3: API Interceptor (Frontend/Backend)            │
│  ┌──────────────────────────────────────────────────┐   │
│  │ axios.interceptors.response.use(                 │   │
│  │   response => response,                          │   │
│  │   error => {                                     │   │
│  │     if (error.status === 401) {                  │   │
│  │       Clear auth & redirect to login             │   │
│  │     }                                             │   │
│  │   }                                              │   │
│  │ )                                                │   │
│  │                                                   │   │
│  │ Check: Catch unauthorized API responses          │   │
│  └──────────────────────────────────────────────────┘   │
│                          ▼                                 │
│                                                            │
│  LAYER 4: Backend JWT Filter (Backend)                   │
│  ┌──────────────────────────────────────────────────┐   │
│  │ @Component                                       │   │
│  │ public class JwtFilter extends OncePerRequest... │   │
│  │ {                                                │   │
│  │   protected void doFilterInternal(...) {         │   │
│  │     Extract JWT from Authorization header       │   │
│  │     Validate JWT using JwtUtil                  │   │
│  │     If invalid → Return 401                      │   │
│  │     If valid → Set user context                  │   │
│  │   }                                              │   │
│  │ }                                                │   │
│  │                                                   │   │
│  │ Check: Verify every request has valid JWT        │   │
│  └──────────────────────────────────────────────────┘   │
│                                                            │
│  Result: Multiple checkpoints prevent unauthorized        │
│          access from many angles                          │
│                                                            │
└───────────────────────────────────────────────────────────┘
```

## 7. Component Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                      React Component Tree                         │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│                          App.js                                   │
│                            │                                      │
│            ┌───────────────┼───────────────────┐                 │
│            │               │                   │                 │
│         Navbar          Routes                 │                 │
│            │          ┌─────────────────────┐  │                 │
│            │          │                     │  │                 │
│            │       Home (public)             │  │                 │
│            │       Register (public)         │  │                 │
│            │       Login (public)            │  │                 │
│            │       Dashboard (protected)     │  │                 │
│            │       Profile (protected)       │  │                 │
│            │                                 │  │                 │
│            │    Components inside ProtectedRoute:              │
│            │    ┌──────────────────────┐    │  │                 │
│            │    │  ProtectedRoute      │    │  │                 │
│            │    │  - Check token       │    │  │                 │
│            │    │  - Redirect if none  │    │  │                 │
│            │    │                      │    │  │                 │
│            │    │  ├─ Dashboard        │    │  │                 │
│            │    │  │  - useEffect auth │    │  │                 │
│            │    │  │  - Logout button  │    │  │                 │
│            │    │  │  - User stats     │    │  │                 │
│            │    │  │                   │    │  │                 │
│            │    │  └─ Profile          │    │  │                 │
│            │    │     - useEffect auth │    │  │                 │
│            │    │     - User table     │    │  │                 │
│            │    │     - API call       │    │  │                 │
│            │    │                      │    │  │                 │
│            │    └──────────────────────┘    │  │                 │
│            │                                 │  │                 │
│            └─────────────────────────────────┘  │                 │
│                                                   │                 │
│  Services Used:                                   │                 │
│  ├─ authService.js                              │                 │
│  │  ├─ register()                                │                 │
│  │  ├─ login()                                   │                 │
│  │  ├─ logout()                                  │                 │
│  │  ├─ isLoggedIn()                              │                 │
│  │  ├─ getStoredToken()                          │                 │
│  │  ├─ getStoredUser()                           │                 │
│  │  └─ clearAuth()                               │                 │
│  │                                                │                 │
│  └─ api.js                                       │                 │
│     ├─ Axios instance                            │                 │
│     ├─ Request interceptor (add token)           │                 │
│     └─ Response interceptor (handle 401)         │                 │
│                                                   │                 │
└─────────────────────────────────────────────────────────────────┘
```

## 8. Database Schema Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                      users Table                              │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌────────────────────────────────────────────────────────┐ │
│  │ Column              │ Type         │ Constraints       │ │
│  ├────────────────────────────────────────────────────────┤ │
│  │ id                  │ BIGINT       │ PK, AUTO_INCREMENT│ │
│  │ full_name           │ VARCHAR(255) │                    │ │
│  │ email               │ VARCHAR(255) │ UNIQUE, NOT NULL  │ │
│  │ mobile              │ VARCHAR(20)  │                    │ │
│  │ username            │ VARCHAR(255) │ UNIQUE, NOT NULL  │ │
│  │ password            │ VARCHAR(255) │ NOT NULL          │ │
│  │                     │              │ (BCrypt hashed)   │ │
│  │ role                │ VARCHAR(50)  │ DEFAULT 'USER'    │ │
│  │ profile_image       │ VARCHAR(255) │                    │ │
│  │ created_at          │ TIMESTAMP    │ DEFAULT NOW()     │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                               │
│  Indexes:                                                     │
│  - idx_username (username)  - For faster user lookups        │
│  - idx_email (email)        - For faster email lookups       │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

## 9. Token Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│                  JWT TOKEN LIFECYCLE                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  1. GENERATION (During Login)                               │
│     ┌──────────────────────────────────────────────────┐    │
│     │ JwtUtil.generateToken(username)                 │    │
│     │                                                   │    │
│     │ Claims:                                          │    │
│     │ {                                                │    │
│     │   "sub": "testuser",        // Subject          │    │
│     │   "iat": 1688014000,         // Issued at       │    │
│     │   "exp": 1688100400,         // Expiration      │    │
│     │   "alg": "HS512",            // Algorithm       │    │
│     │   "signature": "..."         // HMAC signature  │    │
│     │ }                                                │    │
│     │                                                   │    │
│     │ Result: eyJhbGciOiJIUzUxMiJ9...token...         │    │
│     └──────────────────────────────────────────────────┘    │
│                          ▼                                    │
│                                                               │
│  2. STORAGE (Frontend)                                       │
│     ┌──────────────────────────────────────────────────┐    │
│     │ localStorage.setItem('token', token)             │    │
│     │                                                   │    │
│     │ Browser Storage:                                 │    │
│     │ {                                                │    │
│     │   "token": "eyJhbGc...",                         │    │
│     │   "user": "{...}",                               │    │
│     │   "username": "testuser"                         │    │
│     │ }                                                │    │
│     └──────────────────────────────────────────────────┘    │
│                          ▼                                    │
│                                                               │
│  3. TRANSMISSION (Every Request)                            │
│     ┌──────────────────────────────────────────────────┐    │
│     │ GET /api/users                                   │    │
│     │ Authorization: Bearer eyJhbGc...                 │    │
│     │                                                   │    │
│     │ api.js Request Interceptor adds:                │    │
│     │ config.headers.Authorization = `Bearer ${token}`│    │
│     └──────────────────────────────────────────────────┘    │
│                          ▼                                    │
│                                                               │
│  4. VALIDATION (Backend)                                     │
│     ┌──────────────────────────────────────────────────┐    │
│     │ JwtFilter.doFilterInternal()                     │    │
│     │                                                   │    │
│     │ 1. Extract token from Authorization header      │    │
│     │ 2. Call JwtUtil.validateToken(token)             │    │
│     │ 3. Call JwtUtil.getUsernameFromToken(token)      │    │
│     │ 4. Load UserDetails from database                │    │
│     │ 5. Create UsernamePasswordAuthenticationToken    │    │
│     │ 6. Set SecurityContextHolder                     │    │
│     │                                                   │    │
│     │ If invalid → Return 401 Unauthorized             │    │
│     └──────────────────────────────────────────────────┘    │
│                          ▼                                    │
│                                                               │
│  5. USAGE (Backend Processing)                              │
│     ┌──────────────────────────────────────────────────┐    │
│     │ SecurityContext.getAuthentication()              │    │
│     │ → Returns UsernamePasswordAuthenticationToken   │    │
│     │ → Controller/Service can access user info        │    │
│     │                                                   │    │
│     │ Return 200 OK with response                      │    │
│     └──────────────────────────────────────────────────┘    │
│                          ▼                                    │
│                                                               │
│  6. EXPIRATION (Automatic)                                   │
│     ┌──────────────────────────────────────────────────┐    │
│     │ Check: token.exp < current_time                  │    │
│     │                                                   │    │
│     │ If expired:                                      │    │
│     │ ├─ JwtFilter returns 401 Unauthorized            │    │
│     │ └─ API Interceptor catches 401                   │    │
│     │    ├─ Clear localStorage                         │    │
│     │    ├─ Navigate to /login                         │    │
│     │    └─ Force re-login                             │    │
│     └──────────────────────────────────────────────────┘    │
│                                                               │
│  7. LOGOUT (Manual)                                          │
│     ┌──────────────────────────────────────────────────┐    │
│     │ User clicks Logout                               │    │
│     │ ├─ Call logout endpoint                          │    │
│     │ ├─ Clear token from localStorage                 │    │
│     │ ├─ Token still valid on backend (optional)       │    │
│     │ │  (Implement token blacklist in production)     │    │
│     │ └─ Navigate to /login                            │    │
│     │                                                   │    │
│     │ Next request without token → 401 Unauthorized    │    │
│     └──────────────────────────────────────────────────┘    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## 10. Error Handling Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  ERROR HANDLING FLOW                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  Frontend Error                                              │
│       │                                                      │
│       ├─ Registration Error                                 │
│       │  ├─ Empty fields → Show validation message         │
│       │  ├─ Invalid email → Show format error              │
│       │  ├─ Password mismatch → Show mismatch error        │
│       │  ├─ Duplicate username → Show specific error       │
│       │  └─ Duplicate email → Show specific error          │
│       │                                                      │
│       ├─ Login Error                                        │
│       │  ├─ Empty fields → Show validation message         │
│       │  ├─ Wrong password → Show invalid credentials      │
│       │  ├─ User not found → Show invalid credentials      │
│       │  └─ Network error → Show connection error          │
│       │                                                      │
│       ├─ API Error                                          │
│       │  ├─ 400 Bad Request → Show specific error          │
│       │  ├─ 401 Unauthorized → Clear auth, redirect login  │
│       │  ├─ 404 Not Found → Show not found error           │
│       │  ├─ 500 Server Error → Show server error           │
│       │  └─ Network Error → Show connection error          │
│       │                                                      │
│       └─ Logout Error                                       │
│          ├─ API Error → Clear auth anyway                  │
│          └─ Always redirect to login                        │
│                                                               │
│  Backend Error                                               │
│       │                                                      │
│       ├─ Register Error                                     │
│       │  ├─ Duplicate username → 400 Bad Request          │
│       │  ├─ Duplicate email → 400 Bad Request             │
│       │  ├─ Invalid data → 400 Bad Request                │
│       │  └─ Database error → 500 Server Error             │
│       │                                                      │
│       ├─ Login Error                                        │
│       │  ├─ Invalid credentials → 401 Unauthorized        │
│       │  ├─ User not found → 401 Unauthorized             │
│       │  └─ Database error → 500 Server Error             │
│       │                                                      │
│       └─ JWT Validation Error                               │
│          ├─ No token → 401 Unauthorized                    │
│          ├─ Invalid token → 401 Unauthorized              │
│          ├─ Expired token → 401 Unauthorized              │
│          └─ Tampered token → 401 Unauthorized             │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Takeaways

1. **Multiple Security Layers**: Frontend route protection + component validation + API interceptor + backend JWT validation

2. **Token Flow**: Generation → Storage → Transmission → Validation → Usage → Expiration/Logout

3. **Browser History**: Using `navigate(path, { replace: true })` prevents back button from reopening protected pages

4. **Error Messages**: Specific errors from backend are shown to user, not generic "failed" messages

5. **State Consistency**: localStorage is the single source of truth for authentication state

6. **Automatic Logout**: 401 responses from API automatically clear auth and redirect to login

7. **Component Protection**: Each protected component has its own useEffect that validates authentication as a safety net
