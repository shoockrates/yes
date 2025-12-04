-- ============================================================
-- SCHEMA KŪRIMAS
-- ============================================================
CREATE SCHEMA IF NOT EXISTS kisp0844;


-- ============================================================
-- LENTELĖS (4 pagrindinės + 3 ryšių lentelės = 7 lentelės)
-- ============================================================

-- Lentelė 1: Varzybos
CREATE TABLE kisp0844.Varzybos (
    VarzybuId INTEGER NOT NULL PRIMARY KEY,
    ArReitinguojamas BOOLEAN NOT NULL,
    Vieta VARCHAR(30) NOT NULL,
    Data DATE DEFAULT CURRENT_DATE,
    Kategorija VARCHAR(2) NOT NULL,
    MaksimalusZaidejusKiekis SMALLINT DEFAULT 0 NOT NULL,
    Ivertinimas SMALLINT CHECK (Ivertinimas BETWEEN 0 AND 100)
);

-- Lentelė 2: Zaidejai
CREATE TABLE kisp0844.Zaidejai (
    ZaidejoId INTEGER NOT NULL PRIMARY KEY,
    Pavarde VARCHAR(30) NOT NULL,   
    GimimoData DATE DEFAULT CURRENT_DATE,
    Vardas VARCHAR(30) NOT NULL,
    Reitingas SMALLINT DEFAULT 1500 CHECK (Reitingas BETWEEN 1000 AND 2800),
    Adresas VARCHAR(50) NOT NULL,
    Gatve VARCHAR(30) NOT NULL,
    Namas VARCHAR(10) NOT NULL,
    Butas VARCHAR(10) NOT NULL
);

-- Lentelė 3: Partijos
CREATE TABLE kisp0844.Partijos (
    ID INTEGER NOT NULL PRIMARY KEY,
    Varzybu_Id INTEGER NOT NULL,
    LentosNr SMALLINT NOT NULL,
    Turas SMALLINT NOT NULL,
    Rezultatas VARCHAR(10) NOT NULL,
    FOREIGN KEY (Varzybu_Id) REFERENCES kisp0844.Varzybos(VarzybuId) ON DELETE CASCADE,
    CONSTRAINT chk_rezultatas CHECK (Rezultatas IN ('1-0', '0-1', '½-½'))
);

-- Lentelė 4: ParasytasAtsiliepiamas (M:N ryšys tarp Varzybos ir Zaidejai)
CREATE TABLE kisp0844.ParasytasAtsiliepiamas (
    ZaidejoId INTEGER NOT NULL,
    VarzybuId INTEGER NOT NULL,
    PRIMARY KEY (ZaidejoId, VarzybuId),
    FOREIGN KEY (ZaidejoId) REFERENCES kisp0844.Zaidejai(ZaidejoId) ON DELETE CASCADE,
    FOREIGN KEY (VarzybuId) REFERENCES kisp0844.Varzybos(VarzybuId) ON DELETE CASCADE
);

-- Lentelė 5: ZaidziaBaltais (M:N ryšys - partijos su baltais)
CREATE TABLE kisp0844.ZaidziaBaltais (
    PartijosID INTEGER NOT NULL,
    ZaidejoId INTEGER NOT NULL,
    PRIMARY KEY (PartijosID, ZaidejoId),
    FOREIGN KEY (PartijosID) REFERENCES kisp0844.Partijos(ID) ON DELETE CASCADE,
    FOREIGN KEY (ZaidejoId) REFERENCES kisp0844.Zaidejai(ZaidejoId) ON DELETE CASCADE
);

-- Lentelė 6: ZaidziaJuodais (1:N ryšys - partijos su juodais)
CREATE TABLE kisp0844.ZaidziaJuodais (
    PartijosID INTEGER NOT NULL PRIMARY KEY,
    ZaidejoId INTEGER NOT NULL,
    FOREIGN KEY (PartijosID) REFERENCES kisp0844.Partijos(ID) ON DELETE CASCADE,
    FOREIGN KEY (ZaidejoId) REFERENCES kisp0844.Zaidejai(ZaidejoId) ON DELETE CASCADE
);


-- ============================================================
-- INDEKSAI (Unikalus #1, Neunikalus #1, #2)
-- ============================================================
CREATE UNIQUE INDEX idx_varzybos_vieta_data ON kisp0844.Varzybos (Vieta, Data);
CREATE INDEX idx_zaidejai_pavarde ON kisp0844.Zaidejai (Pavarde);
CREATE INDEX idx_partijos_varzybu ON kisp0844.Partijos (Varzybu_Id);


-- ============================================================
-- VIRTUALIOSIOS LENTELĖS (2 virtualiosios)
-- ============================================================

-- Virtualioji lentelė #1: Varzybų partijos
CREATE VIEW kisp0844.VarzybuPartijos AS
SELECT 
    V.VarzybuId,
    V.Vieta AS VarzybuPavadinimas, 
    P.ID AS PartijosID, 
    P.Rezultatas
FROM kisp0844.Varzybos V
JOIN kisp0844.Partijos P ON V.VarzybuId = P.Varzybu_Id;

-- Virtualioji lentelė #2: Sporto meistrai (reitingas > 2100)
CREATE VIEW kisp0844.SportoMeistrai AS
SELECT 
    Zaidejai.ZaidejoId,
    Zaidejai.Pavarde,
    Zaidejai.GimimoData,
    Zaidejai.Vardas,
    Zaidejai.Reitingas
FROM kisp0844.Zaidejai
WHERE Zaidejai.Reitingas > 2100;

-- Virtualioji lentelė #3: Varžybų dalyviai
CREATE VIEW kisp0844.VarzybuDalyviai AS
SELECT 
    V.VarzybuId,
    V.Vieta AS Varzybos,
    V.Data,
    Z.ZaidejoId,
    Z.Vardas || ' ' || Z.Pavarde AS Dalyvis,
    Z.Reitingas
FROM kisp0844.Varzybos V
JOIN kisp0844.Partijos P ON V.VarzybuId = P.Varzybu_Id
LEFT JOIN kisp0844.ZaidziaBaltais ZB ON P.ID = ZB.PartijosID
LEFT JOIN kisp0844.ZaidziaJuodais ZJ ON P.ID = ZJ.PartijosID
LEFT JOIN kisp0844.Zaidejai Z ON Z.ZaidejoId IN (ZB.ZaidejoId, ZJ.ZaidejoId)
WHERE Z.ZaidejoId IS NOT NULL
GROUP BY V.VarzybuId, V.Vieta, V.Data, Z.ZaidejoId, Z.Vardas, Z.Pavarde, Z.Reitingas
ORDER BY V.Data, Z.Pavarde;


-- ============================================================
-- MATERIALIZUOTA VIRTUALIOJI LENTELĖ
-- ============================================================
CREATE MATERIALIZED VIEW kisp0844.VidutiniaiReitingai AS
SELECT 
    V.VarzybuId AS VarzybuID, 
    V.Vieta AS Pavadinimas, 
    ROUND(AVG(Z.Reitingas), 2) AS VidutinisReitingas
FROM kisp0844.Varzybos V
JOIN kisp0844.Partijos P ON V.VarzybuId = P.Varzybu_Id
LEFT JOIN kisp0844.ZaidziaBaltais ZB ON P.ID = ZB.PartijosID
LEFT JOIN kisp0844.ZaidziaJuodais ZJ ON P.ID = ZJ.PartijosID
LEFT JOIN kisp0844.Zaidejai Z ON Z.ZaidejoId IN (ZB.ZaidejoId, ZJ.ZaidejoId)
GROUP BY V.VarzybuId, V.Vieta;


-- ============================================================
-- DALYKINĖS TAISYKLĖS - FUNKCIJOS IR TRIGERIAI
-- ============================================================

-- Funkcija #1: Automatinis žaidėjų kiekio atnaujinimas
CREATE OR REPLACE FUNCTION kisp0844.atnaujintiZaidejuKieki()
RETURNS TRIGGER AS $$
BEGIN 
    UPDATE kisp0844.Varzybos AS V
    SET MaksimalusZaidejusKiekis = (
        SELECT COUNT(DISTINCT Z.ZaidejoId)
        FROM kisp0844.Partijos P
        LEFT JOIN kisp0844.ZaidziaBaltais ZB ON P.ID = ZB.PartijosID
        LEFT JOIN kisp0844.ZaidziaJuodais ZJ ON P.ID = ZJ.PartijosID
        LEFT JOIN kisp0844.Zaidejai Z ON Z.ZaidejoId IN (ZB.ZaidejoId, ZJ.ZaidejoId)
        WHERE P.Varzybu_Id = COALESCE(NEW.Varzybu_Id, OLD.Varzybu_Id)
    )
    WHERE V.VarzybuId = COALESCE(NEW.Varzybu_Id, OLD.Varzybu_Id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Trigeris #1
CREATE TRIGGER trigger_update_zaideju_kiekis
AFTER INSERT OR DELETE ON kisp0844.Partijos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.atnaujintiZaidejuKieki();


-- Funkcija #2: Unikalios varzybos (vieta + data)
CREATE OR REPLACE FUNCTION kisp0844.unikalios_varzybos()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM kisp0844.Varzybos V
        WHERE V.Vieta = NEW.Vieta 
          AND V.Data = NEW.Data
          AND V.VarzybuId != NEW.VarzybuId
    )
    THEN 
        RAISE EXCEPTION 'Dvi varzybos negali vykti ten pat tuo pačiu laiku!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigeris #2
CREATE TRIGGER trigger_ar_unikalios_varzybos
BEFORE INSERT OR UPDATE ON kisp0844.Varzybos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.unikalios_varzybos();


-- Funkcija #3: Automatinis materializuotos lentelės atnaujinimas
CREATE OR REPLACE FUNCTION kisp0844.refresh_VidutiniaiReitingai()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigeris #3
CREATE TRIGGER trigger_update_avg_reitingas_zaidejai
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.Zaidejai
FOR EACH ROW
EXECUTE FUNCTION kisp0844.refresh_VidutiniaiReitingai();

-- Trigeris #4
CREATE TRIGGER trigger_update_avg_reitingas_partijos
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.Partijos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.refresh_VidutiniaiReitingai();


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
-- DUOMENŲ UŽPILDYMAS - ZAIDEJAI (tikri šachmatininkai)
-- ============================================================
INSERT INTO kisp0844.Zaidejai (ZaidejoId, Pavarde, GimimoData, Vardas, Reitingas, Adresas, Gatve, Namas, Butas)
VALUES 
    -- Pasaulio čempionai ir top žaidėjai
    (1, 'Carlsen', '1990-11-30', 'Magnus', 2830, 'Oslo', 'Stortingsgata', '15', '42'),
    (2, 'Caruana', '1992-07-30', 'Fabiano', 2805, 'Miami', 'Brickell Ave', '1200', '87'),
    (3, 'Ding', '1992-10-24', 'Liren', 2788, 'Shanghai', 'Nanjing Road', '888', '23'),
    (4, 'Nepomniachtchi', '1990-07-14', 'Ian', 2771, 'Moscow', 'Tverskaya St', '10', '5'),
    (5, 'Nakamura', '1987-12-09', 'Hikaru', 2768, 'Los Angeles', 'Hollywood Blvd', '6801', '15'),
    
    -- Europos žaidėjai
    (6, 'Giri', '1994-06-28', 'Anish', 2749, 'Amsterdam', 'Prinsengracht', '263', '2'),
    (7, 'Aronian', '1982-10-06', 'Levon', 2736, 'Yerevan', 'Baghramyan Ave', '46', '12'),
    (8, 'Grischuk', '1983-10-31', 'Alexander', 2745, 'Moscow', 'Arbat Street', '25', '8'),
    
    -- Jaunieji talentai
    (9, 'Firouzja', '2003-06-18', 'Alireza', 2759, 'Paris', 'Champs-Elysees', '102', '33'),
    (10, 'Keymer', '2004-11-02', 'Vincent', 2690, 'Berlin', 'Unter den Linden', '77', '14'),
    
    -- Lietuvos šachmatininkai (pridedami realistiškumo)
    (11, 'Sulskis', '1988-07-14', 'Sarunas', 2510, 'Vilnius', 'Gedimino pr.', '10', '5'),
    (12, 'Kveinys', '1972-04-06', 'Aloyzas', 2485, 'Kaunas', 'Laisves al.', '56', '12');


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
-- ============================================================
INSERT INTO kisp0844.ZaidziaBaltais (PartijosID, ZaidejoId)
VALUES 
    -- Vilnius matches
    (1, 1),  -- Carlsen
    (2, 3),  -- Ding
    (3, 1),  -- Carlsen
    (4, 6),  -- Giri
    
    -- Kaunas matches
    (5, 3),  -- Ding
    (6, 5),  -- Nakamura
    (7, 3),  -- Ding
    (8, 7),  -- Aronian
    
    -- Klaipeda matches
    (9, 5),  -- Nakamura
    (10, 6),  -- Giri
    (11, 5),  -- Nakamura
    
    -- Siauliai matches
    (12, 7),  -- Aronian
    (13, 8),  -- Grischuk
    (14, 7),  -- Aronian
    
    -- Panevezys matches
    (15, 9),  -- Firouzja
    (16, 9),  -- Firouzja
    (17, 10), -- Keymer
    
    -- Alytus matches (Lietuvos žaidėjai)
    (18, 11), -- Sulskis
    (19, 12), -- Kveinys
    
    -- Marijampole matches
    (20, 1),  -- Carlsen
    (21, 2),  -- Caruana
    (22, 4),  -- Nepomniachtchi
    (23, 9),  -- Firouzja
    
    -- Telsiai
    (24, 6);  -- Giri


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - ZAIDZIAJUODAIS (24 įrašai)
-- ============================================================
INSERT INTO kisp0844.ZaidziaJuodais (PartijosID, ZaidejoId)
VALUES 
    -- Vilnius matches
    (1, 2),   -- Caruana
    (2, 4),   -- Nepomniachtchi
    (3, 2),   -- Caruana
    (4, 5),   -- Nakamura
    
    -- Kaunas matches
    (5, 4),   -- Nepomniachtchi
    (6, 6),   -- Giri
    (7, 4),   -- Nepomniachtchi
    (8, 8),   -- Grischuk
    
    -- Klaipeda matches
    (9, 6),   -- Giri
    (10, 5),  -- Nakamura
    (11, 6),  -- Giri
    
    -- Siauliai matches
    (12, 8),  -- Grischuk
    (13, 7),  -- Aronian
    (14, 8),  -- Grischuk
    
    -- Panevezys matches
    (15, 10), -- Keymer
    (16, 10), -- Keymer
    (17, 9),  -- Firouzja
    
    -- Alytus matches
    (18, 12), -- Kveinys
    (19, 11), -- Sulskis
    
    -- Marijampole matches
    (20, 3),  -- Ding
    (21, 7),  -- Aronian
    (22, 1),  -- Carlsen
    (23, 2),  -- Caruana
    
    -- Telsiai
    (24, 11); -- Sulskis


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - PARASYTASATSILIEPIAMAS (20 įrašų)
-- ============================================================
INSERT INTO kisp0844.ParasytasAtsiliepiamas (ZaidejoId, VarzybuId)
VALUES 
    -- Top players reviewing tournaments
    (1, 1), (2, 1), (3, 1), (4, 1), (5, 1), (6, 1),
    (3, 2), (4, 2), (5, 2), (6, 2), (7, 2), (8, 2),
    (5, 3), (6, 3),
    (7, 4), (8, 4),
    (9, 5), (10, 5),
    (11, 6), (12, 6);


-- ============================================================
-- MATERIALIZUOTOS VIEW ATNAUJINIMAS
-- ============================================================
REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;


-- ============================================================
-- PABAIGA - PRANEŠIMAS IR STATISTIKA
-- ============================================================
\echo ''
\echo '======================================'
\echo 'DB SUKURTA SĖKMINGAI SU TIKRAIS ŠACHMATININKAIS!'
\echo '======================================'
\echo ''
\echo 'Lentelės:'
\dt kisp0844.*
\echo ''
\echo 'View:'
\dv kisp0844.*
\echo ''
\echo 'Materializuotos view:'
\dm kisp0844.*
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
\echo 'Sporto meistrai (>2100):'
SELECT COUNT(*) FROM kisp0844.SportoMeistrai;
