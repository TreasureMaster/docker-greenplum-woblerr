#!/usr/bin/env bash
set -e
# set -a; . .env.pxf; set +a

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
	CREATE USER ${CONFLOG_USERNAME} WITH PASSWORD '${CONFLOG_PASSWORD}';
	CREATE DATABASE ${CONFLOG_DATABASE};
	GRANT ALL PRIVILEGES ON DATABASE ${CONFLOG_DATABASE} TO ${CONFLOG_USERNAME};
	CREATE TABLE users (
		id SERIAL PRIMARY KEY,
		username VARCHAR(50) UNIQUE NOT NULL,
		email VARCHAR(100) UNIQUE,
		age INTEGER CHECK (age >= 0),
		created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
	);
	INSERT INTO users (username, email, age)
	VALUES 
	('cyber_punk', 'punk@neon.city', 20),
	('tech_wizard', 'wizard@code.io', 32),
	('sql_master', NULL, 45);
EOSQL
