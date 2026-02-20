-- Run this ONCE in PostgreSQL (pgAdmin or psql) to fix schema mismatch.
-- Connects to database: project-Tracker
-- This drops the old users table so Hibernate can recreate it correctly.

DROP TABLE IF EXISTS users CASCADE;
