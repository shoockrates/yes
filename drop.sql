-- Drop all triggers first


—-----


DROP TRIGGER IF EXISTS refresh_varzybų_partijos_trigger ON kisp0844.Partijos;
DROP TRIGGER IF EXISTS tikrinti_dalyviu_kieki ON kisp0844.Partijos;

-- Drop all functions
DROP FUNCTION IF EXISTS kisp0844.refresh_varzybų_partijos();
DROP FUNCTION IF EXISTS kisp0844.patikrinti_maksimalu_zaidejų_kieki();

-- Drop materialized views
DROP MATERIALIZED VIEW IF EXISTS kisp0844.VaržybųPartijos CASCADE;

-- Drop views
DROP VIEW IF EXISTS kisp0844.ŽaidėjųStatistika CASCADE;
DROP VIEW IF EXISTS kisp0844.VaržybųDalyviai CASCADE;

-- Drop indexes (optional as they'll be dropped with tables)
DROP INDEX IF EXISTS kisp0844.idx_varzybos_data;
DROP INDEX IF EXISTS kisp0844.idx_partijos_varzybos;
DROP INDEX IF EXISTS kisp0844.idx_partijos_juodu;
DROP INDEX IF EXISTS kisp0844.idx_partijos_baltu;

-- Drop tables in correct order (respecting foreign keys)
DROP TABLE IF EXISTS kisp0844.ParašytasAtsiliepimas CASCADE;
DROP TABLE IF EXISTS kisp0844.Partijos CASCADE;
DROP TABLE IF EXISTS kisp0844.Varžybos CASCADE;
DROP TABLE IF EXISTS kisp0844.Žaidėjai CASCADE;

-- Drop schema
DROP SCHEMA IF EXISTS kisp0844 CASCADE;


