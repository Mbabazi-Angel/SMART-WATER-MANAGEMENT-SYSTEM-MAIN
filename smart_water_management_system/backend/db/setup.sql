CREATE DATABASE NEW_user_db;

USE NEW_user_db;

CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    account_type VARCHAR(50),
    district VARCHAR(100),
    neighborhood VARCHAR(100),
    address TEXT,
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Dummy User 1
INSERT INTO users (first_name, last_name, email, password, account_type, district, neighborhood, address, phone_number)
VALUES ('John', 'Doe', 'john.doe@example.com', 
        '$2a$10$zYOGh4L9c4sh4Q47qHGpz.L2h5AYoIBERJQtmH1MzdNiKXG8z2Te2', -- Hashed password: "password123"
        'admin', 'Kampala', 'Makerere', '123 Street, Kampala', '0701234567');

-- Dummy User 2
INSERT INTO users (first_name, last_name, email, password, account_type, district, neighborhood, address, phone_number)
VALUES ('Jane', 'Smith', 'jane.smith@example.com', 
        '$2a$10$OdQtoZMk85F7Z9Rlm0u7geK6vzxU.5UlfiFWeCUfFQIE99JkVqbq2', -- Hashed password: "password456"
        'user', 'Mbarara', 'Nyamitanga', '456 Street, Mbarara', '0787654321');

-- Dummy User 3
INSERT INTO users (first_name, last_name, email, password, account_type, district, neighborhood, address, phone_number)
VALUES ('Alice', 'Johnson', 'alice.johnson@example.com', 
        '$2a$10$Bl.n51h71t4pQyIMF0.QTeBylI6epzEzntfHfbhgUOqE0.mZJhDuK', -- Hashed password: "password789"
        'user', 'Gulu', 'Layibi', '789 Street, Gulu', '0754432211');

-- Dummy User 4
INSERT INTO users (first_name, last_name, email, password, account_type, district, neighborhood, address, phone_number)
VALUES ('Bob', 'Brown', 'bob.brown@example.com', 
        '$2a$10$zYOGh4L9c4sh4Q47qHGpz.L2h5AYoIBERJQtmH1MzdNiKXG8z2Te2', -- Hashed password: "password123"
        'admin', 'Kampala', 'Kololo', '101 Street, Kampala', '0709876543');


-- Feedback Table
CREATE TABLE feedback (
    id INT AUTO_INCREMENT PRIMARY KEY,
    content TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Leakage Report Table
CREATE TABLE leakage_reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- Table for storing districts (if you want to expand this list in the future)
CREATE TABLE IF NOT EXISTS districts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);

-- Table for storing neighborhoods (you can add a district_id to relate them)
CREATE TABLE IF NOT EXISTS neighborhoods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  district_id INT NOT NULL,
  FOREIGN KEY (district_id) REFERENCES districts(id)
);

-- You can add other tables like bills or alerts if necessary for your project.
