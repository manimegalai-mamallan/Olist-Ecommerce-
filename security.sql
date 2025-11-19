DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'analyst') THEN
        CREATE ROLE analyst;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'app_user') THEN
        CREATE ROLE app_user;
    END IF;
END $$;

-- 3) Grant basic database + schema access
GRANT CONNECT ON DATABASE ecommerce TO analyst, app_user; 
GRANT USAGE  ON SCHEMA public TO analyst, app_user;

-- 4) Table privileges on existing tables in public schema
-- Read-only role: SELECT only
GRANT SELECT ON ALL TABLES IN SCHEMA public TO analyst;

-- Read-write role: full DML
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_user;

-- 5) Sequence privileges (for SERIAL / IDENTITY columns)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO analyst;
GRANT USAGE, SELECT, UPDATE ON ALL SEQUENCES IN SCHEMA public TO app_user;

-- 6) Default privileges for future tables created in this DB/schema

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT ON TABLES TO analyst;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO analyst;

ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT, UPDATE ON SEQUENCES TO app_user;

-- Create login users and attach roles

CREATE ROLE analyst_user LOGIN PASSWORD 'analyst_user_123!';
GRANT analyst TO analyst_user;

CREATE ROLE app_user_login LOGIN PASSWORD 'app_user_123!';
GRANT app_user TO app_user_login;
