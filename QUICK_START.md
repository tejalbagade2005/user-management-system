# Quick Start Guide

## Prerequisites
- Node.js 14+ installed
- Java 17 installed
- MySQL Server running locally
- Maven installed

## Setup Instructions

### 1. Database Setup

Create a MySQL database:

```sql
CREATE DATABASE fullstack_db;
USE fullstack_db;

-- Tables will be created automatically by Hibernate (ddl-auto=update)
-- But here's the schema if you want to create manually:

CREATE TABLE users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255),
  email VARCHAR(255) UNIQUE NOT NULL,
  mobile VARCHAR(20),
  username VARCHAR(255) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'USER',
  profile_image VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_username (username),
  INDEX idx_email (email)
);
```

### 2. Backend Setup

Navigate to backend directory:

```bash
cd backend
```

Update `src/main/resources/application.properties`:

```properties
server.port=8080

# MySQL Configuration - Update with your credentials
spring.datasource.url=jdbc:mysql://localhost:3306/fullstack_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=root
spring.datasource.password=your_mysql_password
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.jpa.hibernate.ddl-auto=update
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
spring.sql.init.mode=never

jwt.secret=ChangeThisSecretForProduction
jwt.expiration=86400000

spring.mvc.pathmatch.matching-strategy=ant_path_matcher
```

Build and run:

```bash
mvn clean install
mvn spring-boot:run
```

Expected output:
```
Tomcat started on port(s): 8080 (http)
```

### 3. Frontend Setup

Navigate to frontend directory:

```bash
cd frontend
```

Create `.env` file:

```
REACT_APP_API_URL=http://localhost:8080/api
```

Install dependencies and run:

```bash
npm install
npm start
```

Frontend will open at `http://localhost:3000`

## Verify Everything Works

1. **Verify Backend is Running**
   - Visit http://localhost:8080/api/users
   - Should see empty array: `[]`

2. **Test Registration**
   - Click "Register" in nav
   - Fill form with:
     - Full Name: John Doe
     - Email: john@example.com
     - Username: johndoe
     - Mobile: 1234567890
     - Password: Password123
     - Confirm: Password123
   - Click Register
   - Should redirect to login page
   - Verify in MySQL: `SELECT * FROM users;`

3. **Test Login**
   - Username: johndoe
   - Password: Password123
   - Click Login
   - Should redirect to Dashboard
   - See "Welcome back, johndoe"

4. **Test Protected Routes**
   - Click Dashboard - should show content
   - Click Profile - should show users table with the new user
   - Try accessing `/dashboard` in new tab while logged in - works
   - Try accessing `/login` while logged in - redirects to dashboard

5. **Test Logout**
   - Click Logout button
   - Should redirect to login
   - Try clicking back button - won't work
   - Try accessing `/dashboard` - redirects to login
   - Check localStorage - should be empty

6. **Test Token Expiration**
   - (Optional) Set `jwt.expiration=60000` (1 minute) in backend
   - Login
   - Wait 1 minute
   - Try accessing Profile page
   - Should redirect to login automatically

## Troubleshooting

### MySQL Connection Error
```
java.sql.SQLException: Access denied for user 'root'@'localhost'
```
**Solution:** Update password in application.properties

### CORS Error
```
Access to XMLHttpRequest at 'http://localhost:8080/api/...' 
from origin 'http://localhost:3000' has been blocked by CORS policy
```
**Solution:** 
- Verify backend is running on 8080
- Check CORS configuration in SecurityConfig.java
- Restart backend after changes

### Port 3000 Already in Use
```bash
# Windows
netstat -ano | findstr :3000
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :3000
kill -9 <PID>
```

### Port 8080 Already in Use
```bash
# Windows
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# macOS/Linux
lsof -i :8080
kill -9 <PID>
```

### Frontend Can't Connect to Backend
- Verify `REACT_APP_API_URL=http://localhost:8080/api` in `.env`
- Restart frontend after changing .env
- Check browser console for error details

### Login Always Fails with "Invalid credentials"
- Verify user exists in database: `SELECT * FROM users WHERE username='johndoe';`
- Try registering a new user
- Check backend logs for authentication errors
- Verify password is correct

## Development Tips

### View Backend Logs
- Check console where `mvn spring-boot:run` is running
- Look for any ERROR or WARN messages

### View Frontend Logs
- Open browser DevTools (F12)
- Go to Console tab
- Check for any errors or warnings
- Network tab shows API calls

### View Database
```bash
mysql -u root -p fullstack_db
mysql> SELECT * FROM users;
```

### Reset Database
```bash
mysql -u root -p fullstack_db
mysql> DROP TABLE users;
mysql> EXIT;
```
Then restart backend to recreate table.

### Clear Browser Storage
- Open DevTools (F12)
- Go to Application tab
- Click Storage → Local Storage → http://localhost:3000
- Delete all entries
- Or use console: `localStorage.clear()`

## Production Deployment

Before deploying to production:

1. **Change JWT Secret**
   ```properties
   jwt.secret=GenerateAStrongRandomStringHere123456789
   ```

2. **Update CORS Origins**
   - In SecurityConfig.java, update `http://localhost:3000` to your production domain

3. **Set Environment Variables**
   - Use environment variables instead of hardcoding DB credentials
   - Set appropriate JWT expiration time

4. **Enable HTTPS**
   - Get SSL certificate
   - Update application.properties with SSL configuration

5. **Implement Token Blacklist**
   - Store invalidated tokens in Redis or database
   - Check blacklist in JwtFilter

6. **Rate Limiting**
   - Add Spring Security rate limiting for auth endpoints
   - Prevent brute force attacks

7. **Logging**
   - Configure proper logging to track security events
   - Monitor for suspicious activities

## Additional Resources

- Spring Security Documentation: https://spring.io/projects/spring-security
- React Router Documentation: https://reactrouter.com
- JWT Best Practices: https://tools.ietf.org/html/rfc8725
- MySQL Documentation: https://dev.mysql.com/doc
