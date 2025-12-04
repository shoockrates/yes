-- ============================================================
-- SIMPLEST: DELETE EVERYTHING YOU OWN
-- ============================================================

\echo 'Deleting all objects owned by you in the database...'

DROP OWNED BY CURRENT_USER CASCADE;

\echo 'Done! All your objects deleted.'
\echo ''

-- Check what remains
\dt kisp0844.*
