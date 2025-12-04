-- ============================================================
-- DUOMENŲ ĮKĖLIMAS - 4 TABLES VERSION
-- ============================================================

-- ============================================================
-- VARZYBOS (8 įrašai)
-- ============================================================
INSERT INTO kisp0844.varzybos (varzybu_id, ar_reitinguojamas, vieta, data, kategorija, maksimalus_zaideju_kiekis, ivertinimas)
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
-- ZAIDEJAI (12 įrašai)
-- ============================================================
INSERT INTO kisp0844.zaidejai (zaidejo_id, pavarde, gimimo_data, vardas, reitingas, adresas, gatve, namas, butas)
VALUES 
    (1, 'Carlsen', '1990-11-30', 'Magnus', 2800, 'Oslo', 'Stortingsgata', '15', '42'),
    (2, 'Caruana', '1992-07-30', 'Fabiano', 2780, 'Miami', 'Brickell Ave', '1200', '87'),
    (3, 'Ding', '1992-10-24', 'Liren', 2750, 'Shanghai', 'Nanjing Road', '888', '23'),
    (4, 'Nepomniachtchi', '1990-07-14', 'Ian', 2740, 'Moscow', 'Tverskaya St', '10', '5'),
    (5, 'Nakamura', '1987-12-09', 'Hikaru', 2730, 'Los Angeles', 'Hollywood Blvd', '6801', '15'),
    (6, 'Giri', '1994-06-28', 'Anish', 2720, 'Amsterdam', 'Prinsengracht', '263', '2'),
    (7, 'Aronian', '1982-10-06', 'Levon', 2700, 'Yerevan', 'Baghramyan Ave', '46', '12'),
    (8, 'Grischuk', '1983-10-31', 'Alexander', 2710, 'Moscow', 'Arbat Street', '25', '8'),
    (9, 'Firouzja', '2003-06-18', 'Alireza', 2725, 'Paris', 'Champs-Elysees', '102', '33'),
    (10, 'Keymer', '2004-11-02', 'Vincent', 2650, 'Berlin', 'Unter den Linden', '77', '14'),
    (11, 'Sulskis', '1988-07-14', 'Sarunas', 2480, 'Vilnius', 'Gedimino pr.', '10', '5'),
    (12, 'Kveinys', '1972-04-06', 'Aloyzas', 2460, 'Kaunas', 'Laisves al.', '56', '12');


-- ============================================================
-- PARTIJOS (24 įrašai) - White and Black players in same row
-- ============================================================
INSERT INTO kisp0844.partijos (id, varzybu_id, baltu_zaidejo_id, juodu_zaidejo_id, lentos_nr, turas, rezultatas)
VALUES 
    -- Vilnius (Carlsen vs Caruana, Ding vs Nepomniachtchi, Giri vs Nakamura)
    (1, 1, 1, 2, 1, 1, '½-½'),    -- Carlsen(W) vs Caruana(B)
    (2, 1, 3, 4, 2, 1, '1-0'),    -- Ding(W) vs Nepomniachtchi(B)
    (3, 1, 1, 2, 1, 2, '0-1'),    -- Carlsen(W) vs Caruana(B)
    (4, 1, 6, 5, 2, 2, '½-½'),    -- Giri(W) vs Nakamura(B)

    -- Kaunas (Ding vs Nepomniachtchi, Nakamura vs Giri, Aronian vs Grischuk)
    (5, 2, 3, 4, 1, 1, '1-0'),    -- Ding(W) vs Nepomniachtchi(B)
    (6, 2, 5, 6, 2, 1, '½-½'),    -- Nakamura(W) vs Giri(B)
    (7, 2, 3, 4, 1, 2, '½-½'),    -- Ding(W) vs Nepomniachtchi(B)
    (8, 2, 7, 8, 2, 2, '0-1'),    -- Aronian(W) vs Grischuk(B)

    -- Klaipeda (Nakamura vs Giri)
    (9, 3, 5, 6, 1, 1, '1-0'),    -- Nakamura(W) vs Giri(B)
    (10, 3, 6, 5, 2, 1, '0-1'),   -- Giri(W) vs Nakamura(B)
    (11, 3, 5, 6, 1, 2, '½-½'),   -- Nakamura(W) vs Giri(B)

    -- Siauliai (Aronian vs Grischuk)
    (12, 4, 7, 8, 1, 1, '½-½'),   -- Aronian(W) vs Grischuk(B)
    (13, 4, 8, 7, 2, 1, '1-0'),   -- Grischuk(W) vs Aronian(B)
    (14, 4, 7, 8, 1, 2, '0-1'),   -- Aronian(W) vs Grischuk(B)

    -- Panevezys (Firouzja vs Keymer)
    (15, 5, 9, 10, 1, 1, '1-0'),  -- Firouzja(W) vs Keymer(B)
    (16, 5, 9, 10, 2, 1, '1-0'),  -- Firouzja(W) vs Keymer(B)
    (17, 5, 10, 9, 1, 2, '½-½'),  -- Keymer(W) vs Firouzja(B)

    -- Alytus (Lithuanian players: Sulskis vs Kveinys)
    (18, 6, 11, 12, 1, 1, '1-0'), -- Sulskis(W) vs Kveinys(B)
    (19, 6, 12, 11, 1, 2, '0-1'), -- Kveinys(W) vs Sulskis(B)

    -- Marijampole (Mixed top players)
    (20, 7, 1, 3, 1, 1, '1-0'),   -- Carlsen(W) vs Ding(B)
    (21, 7, 2, 7, 2, 1, '½-½'),   -- Caruana(W) vs Aronian(B)
    (22, 7, 4, 1, 1, 2, '0-1'),   -- Nepomniachtchi(W) vs Carlsen(B)
    (23, 7, 9, 2, 2, 2, '1-0'),   -- Firouzja(W) vs Caruana(B)

    -- Telsiai
    (24, 8, 6, 11, 1, 1, '½-½');  -- Giri(W) vs Sulskis(B)


-- ============================================================
-- PARASYTASATSILIEPIAMAS (28 įrašų)
-- ============================================================
INSERT INTO kisp0844.parasytasatsiliepiamas (zaidejo_id, varzybu_id)
VALUES 
    -- Vilnius reviews
    (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1),
    -- Kaunas reviews
    (3, 2), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),
    -- Klaipeda reviews
    (5, 3), (6, 3),
    -- Siauliai reviews
    (7, 4), (8, 4),
    -- Panevezys reviews
    (9, 5), (10, 5),
    -- Alytus reviews
    (11, 6), (12, 6),
    -- Marijampole reviews
    (1, 7), (2, 7), (4, 7), (9, 7),
    -- Telsiai reviews
    (6, 8), (11, 8);


-- ============================================================
-- MATERIALIZUOTOS VIEW ATNAUJINIMAS
-- ============================================================
REFRESH MATERIALIZED VIEW kisp0844.vidutiniai_reitingai;


-- ============================================================
-- STATISTIKA
-- ============================================================
\echo ''
\echo '======================================'
\echo 'DUOMENYS ĮKELTI SĖKMINGAI!'
\echo '======================================'
\echo ''

SELECT 'varzybos' as lentele, COUNT(*) as irasu FROM kisp0844.varzybos
UNION ALL
SELECT 'zaidejai', COUNT(*) FROM kisp0844.zaidejai
UNION ALL
SELECT 'partijos', COUNT(*) FROM kisp0844.partijos
UNION ALL
SELECT 'parasytasatsiliepiamas', COUNT(*) FROM kisp0844.parasytasatsiliepiamas;

\echo ''
\echo 'Top 5 žaidėjai pagal reitingą:'

SELECT vardas || ' ' || pavarde AS "Žaidėjas", reitingas 
FROM kisp0844.zaidejai 
ORDER BY reitingas DESC 
LIMIT 5;

\echo ''
\echo 'Sporto meistrai (>2100):'
SELECT COUNT(*) FROM kisp0844.sporto_meistrai;

\echo ''
\echo 'Vidutiniai reitingai:'
SELECT * FROM kisp0844.vidutiniai_reitingai ORDER BY vidutinis_reitingas DESC;
