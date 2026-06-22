-- CyberCorp sample database for enumeration practice
USE corpdb;

CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50),
    department VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO employees (username, department, email) VALUES
    ('jsmith', 'IT', 'jsmith@cybercorp.local'),
    ('mjones', 'Finance', 'mjones@cybercorp.local'),
    ('awilson', 'HR', 'awilson@cybercorp.local'),
    ('tbrown', 'Engineering', 'tbrown@cybercorp.local');

CREATE TABLE IF NOT EXISTS systems (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(100),
    ip_address VARCHAR(20),
    os VARCHAR(50)
);

INSERT INTO systems (hostname, ip_address, os) VALUES
    ('web01', '10.0.1.5', 'Ubuntu 22.04'),
    ('db01', '10.0.1.6', 'Ubuntu 22.04'),
    ('dc01', '10.0.1.10', 'Windows Server 2019');
