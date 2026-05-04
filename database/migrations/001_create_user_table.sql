CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE,
    name VARCHAR(100),
    password VARCHAR(100)
);