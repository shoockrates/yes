-- ============================================================
-- DATABASE CLEANUP SCRIPT
-- Removes all objects in kisp0844 schema
-- ============================================================

\echo '================================================'
\echo 'Starting cleanup process...'
\echo '================================================'
\echo ''

-- Show what exists before cleanup
\echo 'Current objects in kisp0844 schema:'
\dt kisp0844.*
\echo ''

-- Drop the schema and all its contents
\echo 'Dropping kisp0844 schema and all objects...'
DROP SCHEMA IF EXISTS kisp0844 CASCADE;

\echo 'Schema dropped successfully.'
\echo ''

-- Recreate empty schema for fresh start
\echo 'Recreating empty kisp0844 schema...'
CREATE SCHEMA kisp0844;

\echo 'Empty schema created.'
\echo ''

-- Alternative: nuclear option (use with caution)
-- Uncomment if you want to delete ALL objects you own across entire database
-- \echo 'WARNING: Deleting ALL objects owned by current user...'
-- DROP OWNED BY CURRENT_USER CASCADE;

-- Verify cleanup
\echo '================================================'
\echo 'Cleanup complete! Verifying...'
\echo '================================================'
\echo ''
\echo 'Remaining objects in kisp0844 schema:'
\dt kisp0844.*
\echo ''
\echo 'If empty, cleanup was successful.'
\echo 'You can now run your schema creation script.'
\echo ''
