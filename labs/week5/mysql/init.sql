-- Week 5 enumeration lab: 'employees' database for MySQL enumeration practice.
-- Loaded automatically by mysql:8 from /docker-entrypoint-initdb.d on first start.
-- The database is created from MYSQL_DATABASE=employees; the ALTER USER below
-- switches root to mysql_native_password so the Kali/MariaDB client can auth.

ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'enumR0ot';
FLUSH PRIVILEGES;

USE employees;

-- Staff roster - the obvious, non-sensitive table.
CREATE TABLE employees (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  username    VARCHAR(64)  NOT NULL,
  full_name   VARCHAR(128) NOT NULL,
  department  VARCHAR(64),
  title       VARCHAR(128),
  email       VARCHAR(128),
  hire_date   DATE
);

INSERT INTO employees (username, full_name, department, title, email, hire_date) VALUES
  ('jdoe',        'Jane Doe',             'IT',         'Network Engineer',          'jdoe@enum.lab',        '2021-03-15'),
  ('asmith',      'Alex Smith',           'Support',    'Helpdesk Technician',       'asmith@enum.lab',      '2022-07-01'),
  ('adminservice','Backup Service Account','IT',        'Automated Backup Account',  'adminservice@enum.lab','2020-01-10'),
  ('mharrison',   'Marcus Harrison',      'Executive',  'Chief Information Sec Officer','mharrison@enum.lab','2018-11-05'),
  ('ckent',       'Clark Kent',           'Editorial',  'Staff Writer',              'ckent@enum.lab',       '2023-02-14');

-- Department reference table.
CREATE TABLE departments (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(64) NOT NULL,
  manager     VARCHAR(64),
  budget_code VARCHAR(32)
);

INSERT INTO departments (name, manager, budget_code) VALUES
  ('IT',        'Jane Doe',        'IT-100'),
  ('Support',   'Alex Smith',      'SUP-200'),
  ('Executive', 'Marcus Harrison', 'EXEC-001'),
  ('Editorial', 'Clark Kent',      'EDIT-300');

-- SENSITIVE: payroll data. The whole point of "discover sensitive data"
-- during enumeration. Never expose on a real engagement without need-to-know.
CREATE TABLE salaries (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  employee_id    INT NOT NULL,
  annual_salary  DECIMAL(10,2) NOT NULL,
  bank_account   VARCHAR(34),
  confidential   BOOLEAN DEFAULT TRUE
);

INSERT INTO salaries (employee_id, annual_salary, bank_account, confidential) VALUES
  (1,  98000.00, 'GB29-NWBK-6016-1331-9268', TRUE),
  (2,  54000.00, 'GB29-NWBK-6016-1331-4421', TRUE),
  (3,  61000.00, 'GB29-NWBK-6016-1331-7788', TRUE),
  (4, 240000.00, 'GB29-NWBK-6016-1331-0001', TRUE),
  (5,  47000.00, 'GB29-NWBK-6016-1331-5590', TRUE);

-- System configuration table - leaks the SAME backup password found in LDAP,
-- tying the two enumeration streams together (realistic credential reuse).
CREATE TABLE system_config (
  cfg_key   VARCHAR(64) PRIMARY KEY,
  cfg_value VARCHAR(255)
);

INSERT INTO system_config (cfg_key, cfg_value) VALUES
  ('smtp_relay',     'smtp.internal.enum.lab'),
  ('backup_user',    'adminservice'),
  ('backup_pw',      'BaK-2024-c0ld!'),
  ('admin_portal',   'https://admin.enum.lab'),
  ('helpdesk_phone', '+1-555-0144');
