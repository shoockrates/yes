-- Check current user
SELECT current_user;

-- See all objects in kisp0844 schema with their owners
SELECT 
    schemaname,
    tablename,
    tableowner
FROM pg_tables
WHERE schemaname = 'kisp0844';

-- Check schema owner
SELECT 
    nspname AS schema_name,
    nspowner::regrole AS schema_owner
FROM pg_namespace
WHERE nspname = 'kisp0844';

-- Check your privileges
SELECT 
    grantee,
    privilege_type
FROM information_schema.role_table_grants
WHERE table_schema = 'kisp0844'
AND grantee = current_user;
