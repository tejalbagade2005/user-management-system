# IT Vedant Full Stack User Management System

A full stack **User Management System** built with **React.js** and **Spring Boot** that provides secure authentication, user operations, and MySQL-backed persistence.

---

## Project Description

This project demonstrates a complete user management workflow for modern web applications.  
It includes secure login and registration, JWT-based authentication, protected backend APIs, and a responsive frontend dashboard to manage and display user data stored in MySQL.

---

## Features

- User Registration
- User Login
- Secure Logout
- JWT Authentication
- User Dashboard
- Display Registered Users from MySQL
- REST APIs
- Responsive UI
- Form Validation
- MySQL Database Integration

---

## Technology Stack

### Frontend
- React.js
- Axios

### Backend
- Spring Boot
- Spring Security
- JWT Authentication
- Hibernate / JPA
- Maven

### Database
- MySQL

---

## Project Architecture

```text
React Frontend (UI + Axios)
          |
          v
Spring Boot REST APIs (Controller -> Service -> Repository)
          |
          v
Spring Security + JWT (Authentication & Authorization)
          |
          v
MySQL Database (User Data Storage)
```

---

## Installation Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/tejalbagade2005/user-management-system.git
   cd user-management-system
   ```
2. Configure MySQL database (see Database Configuration section).
3. Run backend application.
4. Run frontend application.
5. Open frontend in your browser.

---

## Backend Setup

1. Go to backend project directory:
   ```bash
   cd backend
   ```
2. Update `application.properties` with MySQL credentials.
3. Build the project:
   ```bash
   mvn clean install
   ```
4. Run the Spring Boot app:
   ```bash
   mvn spring-boot:run
   ```

Backend default URL: `http://localhost:8080`

---

## Frontend Setup

1. Go to frontend project directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Start the frontend server:
   ```bash
   npm start
   ```

Frontend default URL: `http://localhost:3000`

---

## MySQL Database Configuration

Example `application.properties` configuration:

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/user_management
spring.datasource.username=root
spring.datasource.pass=your_mysql_pass
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.dialect=org.hibernate.dialect.MySQL8Dialect
```

Make sure MySQL is running and the database exists:

```sql
CREATE DATABASE user_management;
```

---

## API Endpoints

> Adjust endpoint paths if your controller mappings differ.

### Authentication APIs
- `POST /api/auth/register` — Register a new user
- `POST /api/auth/login` — Login and receive JWT token
- `POST /api/auth/logout` — Logout user

### User APIs
- `GET /api/users` — Get all registered users
- `GET /api/users/{id}` — Get user by ID
- `PUT /api/users/{id}` — Update user details
- `DELETE /api/users/{id}` — Delete user

---

## Folder Structure

```text
user-management-system/
├── backend/
│   ├── src/main/java/...         # Controllers, Services, Repositories, Security
│   ├── src/main/resources/
│   │   └── application.properties
│   └── pom.xml
├── frontend/
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   └── services/             # Axios API calls
│   └── package.json
└── README.md
```

---

## Screenshots

Add screenshots of the following pages:

- Login Page
- Registration Page
- User Dashboard
- User List Page

Example:

```markdown
![Login Page](./screenshots/login.png)
![Dashboard](./screenshots/dashboard.png)
```

---

## Future Enhancements

- Role-based access control (Admin/User)
- Email verification and password reset
- Profile image upload
- Search, sort, and pagination for users
- Docker-based deployment

---

## Author

**Tejal Bagade**  
GitHub: [@tejalbagade2005](https://github.com/tejalbagade2005)

---

## License

This project is licensed under the **MIT License**.  
You can add a `LICENSE` file in the repository root for full license text.