-- ============================================================
-- COMPATIBLE DATA INSERTION SCRIPT FOR MODIFIABLE SCHEMA
-- This script populates the kisp0844 schema with junction tables
-- ============================================================

-- ============================================================
-- DUOMENŲ UŽPILDYMAS - VARZYBOS (8 įrašai)
-- ============================================================
INSERT INTO kisp0844.Varzybos (VarzybuId, ArReitinguojamas, Vieta, Data, Kategorija, MaksimalusZaidejusKiekis, Ivertinimas)
VALUES 
    (1, TRUE, 'Vilnius', '2024-01-15', 'A', 0, 85),
    (2, TRUE, 'Kaunas', '2024-02-20', 'B', 0, 90),
    (3, FALSE, 'Klaipeda', '2024-03-10', 'C', 0, 75),
    (4, TRUE, 'Siauliai', '2024-04-05', 'A', 0, 88),
    (5, TRUE, 'Panevezys', '2024-05-12', 'B', 0, 82),
    (6, FALSE, 'Alytus', '2024-06-18', 'C', 0, 70),
    (7, TRUE, 'Marijampole', '2024-07-22', 'A', 0, 95),
    (8, TRUE, 'Telsiai', '2024-08-30', 'B', 0, 78);


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - ZAIDEJAI (12 įrašai - tikri šachmatininkai)
-- ============================================================
INSERT INTO kisp0844.Zaidejai (ZaidejoId, Pavarde, GimimoData, Vardas, Reitingas, Adresas, Gatve, Namas, Butas)
VALUES 
    -- Pasaulio čempionai ir top žaidėjai
    (1, 'Carlsen', '1990-11-30', 'Magnus', 2800, 'Oslo', 'Stortingsgata', '15', '42'),
    (2, 'Caruana', '1992-07-30', 'Fabiano', 2780, 'Miami', 'Brickell Ave', '1200', '87'),
    (3, 'Ding', '1992-10-24', 'Liren', 2750, 'Shanghai', 'Nanjing Road', '888', '23'),
    (4, 'Nepomniachtchi', '1990-07-14', 'Ian', 2740, 'Moscow', 'Tverskaya St', '10', '5'),
    (5, 'Nakamura', '1987-12-09', 'Hikaru', 2730, 'Los Angeles', 'Hollywood Blvd', '6801', '15'),

    -- Europos žaidėjai
    (6, 'Giri', '1994-06-28', 'Anish', 2720, 'Amsterdam', 'Prinsengracht', '263', '2'),
    (7, 'Aronian', '1982-10-06', 'Levon', 2700, 'Yerevan', 'Baghramyan Ave', '46', '12'),
    (8, 'Grischuk', '1983-10-31', 'Alexander', 2710, 'Moscow', 'Arbat Street', '25', '8'),

    -- Jaunieji talentai
    (9, 'Firouzja', '2003-06-18', 'Alireza', 2725, 'Paris', 'Champs-Elysees', '102', '33'),
    (10, 'Keymer', '2004-11-02', 'Vincent', 2650, 'Berlin', 'Unter den Linden', '77', '14'),

    -- Lietuvos šachmatininkai
    (11, 'Sulskis', '1988-07-14', 'Sarunas', 2480, 'Vilnius', 'Gedimino pr.', '10', '5'),
    (12, 'Kveinys', '1972-04-06', 'Aloyzas', 2460, 'Kaunas', 'Laisves al.', '56', '12');


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - PARTIJOS (24 įrašai)
-- ============================================================
INSERT INTO kisp0844.Partijos (ID, Varzybu_Id, LentosNr, Turas, Rezultatas)
VALUES 
    -- Varžybos #1 Vilnius (Carlsen vs Caruana serija)
    (1, 1, 1, 1, '½-½'),
    (2, 1, 2, 1, '1-0'),
    (3, 1, 1, 2, '0-1'),
    (4, 1, 2, 2, '½-½'),

    -- Varžybos #2 Kaunas (Ding vs Nepomniachtchi)
    (5, 2, 1, 1, '1-0'),
    (6, 2, 2, 1, '½-½'),
    (7, 2, 1, 2, '½-½'),
    (8, 2, 2, 2, '0-1'),

    -- Varžybos #3 Klaipeda (Nakamura vs Giri)
    (9, 3, 1, 1, '1-0'),
    (10, 3, 2, 1, '0-1'),
    (11, 3, 1, 2, '½-½'),

    -- Varžybos #4 Siauliai (Aronian vs Grischuk)
    (12, 4, 1, 1, '½-½'),
    (13, 4, 2, 1, '1-0'),
    (14, 4, 1, 2, '0-1'),

    -- Varžybos #5 Panevezys (Firouzja vs Keymer - jauni talentai)
    (15, 5, 1, 1, '1-0'),
    (16, 5, 2, 1, '1-0'),
    (17, 5, 1, 2, '½-½'),

    -- Varžybos #6 Alytus (Lietuvos žaidėjai)
    (18, 6, 1, 1, '1-0'),
    (19, 6, 1, 2, '0-1'),

    -- Varžybos #7 Marijampole (mixed top players)
    (20, 7, 1, 1, '1-0'),
    (21, 7, 2, 1, '½-½'),
    (22, 7, 1, 2, '0-1'),
    (23, 7, 2, 2, '1-0'),

    -- Varžybos #8 Telsiai
    (24, 8, 1, 1, '½-½');


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - ZAIDZIABALTAIS (24 įrašai)
-- Baltieji žaidėjai kiekvienoje partijoje
-- ============================================================
INSERT INTO kisp0844.ZaidziaBaltais (PartijosID, ZaidejoId)
VALUES 
    -- Vilnius matches
    (1, 1),   -- Carlsen vs Caruana
    (2, 3),   -- Ding vs Nepomniachtchi
    (3, 1),   -- Carlsen vs Caruana
    (4, 6),   -- Giri vs Nakamura

    -- Kaunas matches
    (5, 3),   -- Ding vs Nepomniachtchi
    (6, 5),   -- Nakamura vs Giri
    (7, 3),   -- Ding vs Nepomniachtchi
    (8, 7),   -- Aronian vs Grischuk

    -- Klaipeda matches
    (9, 5),   -- Nakamura vs Giri
    (10, 6),  -- Giri vs Nakamura
    (11, 5),  -- Nakamura vs Giri

    -- Siauliai matches
    (12, 7),  -- Aronian vs Grischuk
    (13, 8),  -- Grischuk vs Aronian
    (14, 7),  -- Aronian vs Grischuk

    -- Panevezys matches
    (15, 9),  -- Firouzja vs Keymer
    (16, 9),  -- Firouzja vs Keymer
    (17, 10), -- Keymer vs Firouzja

    -- Alytus matches (Lietuvos žaidėjai)
    (18, 11), -- Sulskis vs Kveinys
    (19, 12), -- Kveinys vs Sulskis

    -- Marijampole matches
    (20, 1),  -- Carlsen vs Ding
    (21, 2),  -- Caruana vs Aronian
    (22, 4),  -- Nepomniachtchi vs Carlsen
    (23, 9),  -- Firouzja vs Caruana

    -- Telsiai
    (24, 6);  -- Giri vs Sulskis


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - ZAIDZIAJUODAIS (24 įrašai)
-- Juodieji žaidėjai kiekvienoje partijoje
-- ============================================================
INSERT INTO kisp0844.ZaidziaJuodais (PartijosID, ZaidejoId)
VALUES 
    -- Vilnius matches
    (1, 2),   -- Carlsen vs Caruana
    (2, 4),   -- Ding vs Nepomniachtchi
    (3, 2),   -- Carlsen vs Caruana
    (4, 5),   -- Giri vs Nakamura

    -- Kaunas matches
    (5, 4),   -- Ding vs Nepomniachtchi
    (6, 6),   -- Nakamura vs Giri
    (7, 4),   -- Ding vs Nepomniachtchi
    (8, 8),   -- Aronian vs Grischuk

    -- Klaipeda matches
    (9, 6),   -- Nakamura vs Giri
    (10, 5),  -- Giri vs Nakamura
    (11, 6),  -- Nakamura vs Giri

    -- Siauliai matches
    (12, 8),  -- Aronian vs Grischuk
    (13, 7),  -- Grischuk vs Aronian
    (14, 8),  -- Aronian vs Grischuk

    -- Panevezys matches
    (15, 10), -- Firouzja vs Keymer
    (16, 10), -- Firouzja vs Keymer
    (17, 9),  -- Keymer vs Firouzja

    -- Alytus matches
    (18, 12), -- Sulskis vs Kveinys
    (19, 11), -- Kveinys vs Sulskis

    -- Marijampole matches
    (20, 3),  -- Carlsen vs Ding
    (21, 7),  -- Caruana vs Aronian
    (22, 1),  -- Nepomniachtchi vs Carlsen
    (23, 2),  -- Firouzja vs Caruana

    -- Telsiai
    (24, 11); -- Giri vs Sulskis


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - PARASYTASATSILIEPIAMAS (20+ įrašų)
-- Žaidėjų atsiliepimai apie varžybas
-- ============================================================
INSERT INTO kisp0844.ParasytasAtsiliepiamas (ZaidejoId, VarzybuId)
VALUES 
    -- Vilnius reviews (top 6 players)
    (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1),

    -- Kaunas reviews
    (3, 2), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),

    -- Klaipeda reviews
    (5, 3), (6, 3),

    -- Siauliai reviews
    (7, 4), (8, 4),

    -- Panevezys reviews
    (9, 5), (10, 5),

    -- Alytus reviews (Lithuanian players)
    (11, 6), (12, 6),

    -- Marijampole reviews
    (1, 7), (2, 7), (4, 7), (9, 7),

    -- Telsiai reviews
    (6, 8), (11, 8);


-- ============================================================
-- MATERIALIZUOTOS VIEW ATNAUJINIMAS
-- ============================================================
REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;


-- ============================================================
-- PABAIGA - PRANEŠIMAS IR STATISTIKA
-- ============================================================
\echo ''
\echo '======================================'
\echo 'DUOMENYS ĮKELTI SĖKMINGAI!'
\echo '======================================'
\echo ''
\echo 'Duomenų skaičius:'

SELECT 'Varzybos' as lentele, COUNT(*) as irasu FROM kisp0844.Varzybos
UNION ALL
SELECT 'Zaidejai', COUNT(*) FROM kisp0844.Zaidejai
UNION ALL
SELECT 'Partijos', COUNT(*) FROM kisp0844.Partijos
UNION ALL
SELECT 'ZaidziaBaltais', COUNT(*) FROM kisp0844.ZaidziaBaltais
UNION ALL
SELECT 'ZaidziaJuodais', COUNT(*) FROM kisp0844.ZaidziaJuodais
UNION ALL
SELECT 'ParasytasAtsiliepiamas', COUNT(*) FROM kisp0844.ParasytasAtsiliepiamas;

\echo ''
\echo 'Top 5 žaidėjai pagal reitingą:'

SELECT Vardas || ' ' || Pavarde AS "Žaidėjas", Reitingas 
FROM kisp0844.Zaidejai 
ORDER BY Reitingas DESC 
LIMIT 5;

\echo ''
\echo 'Sporto meistrai (Reitingas > 2100):'

SELECT COUNT(*) as "Meistru skaicius" FROM kisp0844.SportoMeistrai;

\echo ''
\echo 'Vidutiniai reitingai varžybose:'

SELECT * FROM kisp0844.VidutiniaiReitingai ORDER BY VidutinisReitingas DESC;

\echo ''
\echo '======================================'
\echo 'VISKAS ATLIKTA!'
\echo '======================================'
