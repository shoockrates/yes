-- ============================================================
-- OWNERSHIP DIAGNOSTIC SCRIPT
-- ============================================================

\echo ''
\echo '======================================'
\echo 'CURRENT USER AND OWNERSHIP INFO'
\echo '======================================'
\echo ''

-- Show current user
\echo 'Current connected user:'
SELECT current_user AS "Connected As", 
       session_user AS "Session User";

\echo ''
\echo '======================================'
\echo 'SCHEMA OWNERSHIP'
\echo '======================================'
\echo ''

-- Show schema owner
SELECT 
    nspname AS "Schema Name",
    nspowner::regrole AS "Schema Owner",
    CASE 
        WHEN nspowner::regrole::text = current_user THEN 'YES ✓'
        ELSE 'NO ✗'
    END AS "You Own It?"
FROM pg_namespace
WHERE nspname = 'kisp0844';

\echo ''
\echo '======================================'
\echo 'TABLE OWNERSHIP'
\echo '======================================'
\echo ''

-- Show table owners
SELECT 
    schemaname AS "Schema",
    tablename AS "Table Name",
    tableowner AS "Owner",
    CASE 
        WHEN tableowner = current_user THEN 'YES ✓'
        ELSE 'NO ✗'
    END AS "You Own It?"
FROM pg_tables
WHERE schemaname = 'kisp0844'
ORDER BY tablename;

\echo ''
\echo '======================================'
\echo 'VIEW OWNERSHIP'
\echo '======================================'
\echo ''

-- Show view owners
SELECT 
    schemaname AS "Schema",
    viewname AS "View Name",
    viewowner AS "Owner",
    CASE 
        WHEN viewowner = current_user THEN 'YES ✓'
        ELSE 'NO ✗'
    END AS "You Own It?"
FROM pg_views
WHERE schemaname = 'kisp0844'
ORDER BY viewname;

\echo ''
\echo '======================================'
\echo 'FUNCTION OWNERSHIP'
\echo '======================================'
\echo ''

-- Show function owners
SELECT 
    n.nspname AS "Schema",
    p.proname AS "Function Name",
    pg_get_function_identity_arguments(p.oid) AS "Arguments",
    pg_catalog.pg_get_userbyid(p.proowner) AS "Owner",
    CASE 
        WHEN pg_catalog.pg_get_userbyid(p.proowner) = current_user THEN 'YES ✓'
        ELSE 'NO ✗'
    END AS "You Own It?"
FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'kisp0844'
ORDER BY p.proname;

\echo ''
\echo '======================================'
\echo 'SEQUENCE OWNERSHIP'
\echo '======================================'
\echo ''

-- Show sequence owners
SELECT 
    schemaname AS "Schema",
    sequencename AS "Sequence Name",
    sequenceowner AS "Owner",
    CASE 
        WHEN sequenceowner = current_user THEN 'YES ✓'
        ELSE 'NO ✗'
    END AS "You Own It?"
FROM pg_sequences
WHERE schemaname = 'kisp0844'
ORDER BY sequencename;

\echo ''
\echo '======================================'
\echo 'OWNERSHIP SUMMARY'
\echo '======================================'
\echo ''

-- Summary counts
SELECT 
    'Tables' AS "Object Type",
    COUNT(*) AS "Total",
    COUNT(*) FILTER (WHERE tableowner = current_user) AS "Owned by You",
    COUNT(*) FILTER (WHERE tableowner != current_user) AS "Owned by Others"
FROM pg_tables
WHERE schemaname = 'kisp0844'
UNION ALL
SELECT 
    'Views',
    COUNT(*),
    COUNT(*) FILTER (WHERE viewowner = current_user),
    COUNT(*) FILTER (WHERE viewowner != current_user)
FROM pg_views
WHERE schemaname = 'kisp0844'
UNION ALL
SELECT 
    'Sequences',
    COUNT(*),
    COUNT(*) FILTER (WHERE sequenceowner = current_user),
    COUNT(*) FILTER (WHERE sequenceowner != current_user)
FROM pg_sequences
WHERE schemaname = 'kisp0844';

\echo ''
