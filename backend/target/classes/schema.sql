-- SQL schema for fullstack app
CREATE DATABASE IF NOT EXISTS fullstack_db;
USE fullstack_db;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  full_name VARCHAR(255),
  email VARCHAR(255) UNIQUE,
  mobile VARCHAR(50),
  username VARCHAR(100) UNIQUE,
  password VARCHAR(255),
  role VARCHAR(50),
  profile_image VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS login_history (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT,
  login_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  logout_time TIMESTAMP NULL,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Sample user (password is "password" encoded using BCrypt by application during register; include placeholder)
INSERT IGNORE INTO users (full_name, email, mobile, username, password, role)
VALUES ('Sample User','sample@example.com','1234567890','sampleuser','', 'USER');
