
CREATE ROLE images WITH LOGIN PASSWORD 'images';
CREATE DATABASE images;
GRANT ALL PRIVILEGES ON DATABASE images TO images;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO images;
ALTER ROLE images WITH SUPERUSER;
