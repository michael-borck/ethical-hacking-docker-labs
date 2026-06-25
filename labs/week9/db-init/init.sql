-- Seed data for the internal corporate MySQL database.
-- Runs once on first start of the internal-db container (mysql:8 entrypoint).

USE corpdb;

CREATE TABLE IF NOT EXISTS employees (
    id    INT PRIMARY KEY,
    name  VARCHAR(50),
    role  VARCHAR(50),
    ext   VARCHAR(10)
);

INSERT INTO employees VALUES
    (1, 'Alice Adams', 'CEO',          'x1001'),
    (2, 'Bob Banter',  'IT Operations','x1002'),
    (3, 'Carol Coffee','Finance',      'x1003');

CREATE TABLE IF NOT EXISTS secrets (
    note VARCHAR(120)
);

-- BONUS flag: only reachable after pivoting to the internal database.
INSERT INTO secrets VALUES ('FLAG{deep_dive_db_access}');
