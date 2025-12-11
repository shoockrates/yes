-- Drop statements (for cleanup)
DROP TRIGGER IF EXISTS tikrinti_dalyviu_kieki ON kisp0844.Partijos;

DROP VIEW IF EXISTS kisp0844.ŽaidėjųStatistika;
DROP VIEW IF EXISTS kisp0844.VaržybųDalyviai;

DROP INDEX IF EXISTS kisp0844.idx_varzybos_data;
DROP INDEX IF EXISTS kisp0844.idx_partijos_varzybos;
DROP INDEX IF EXISTS kisp0844.idx_partijos_juodu;
DROP INDEX IF EXISTS kisp0844.idx_partijos_baltu;

DROP TABLE IF EXISTS kisp0844.ParašytasAtsiliepimaS;
DROP TABLE IF EXISTS kisp0844.Partijos;
DROP TABLE IF EXISTS kisp0844.Varžybos;
DROP TABLE IF EXISTS kisp0844.Žaidėjai;

DROP SCHEMA IF EXISTS kisp0844 CASCADE;
