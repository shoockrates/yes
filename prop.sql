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
-- DUOMENŲ UŽPILDYMAS - ZAIDEJAI (10 įrašų)
-- ============================================================
INSERT INTO kisp0844.Zaidejai (ZaidejoId, Pavarde, GimimoData, Vardas, Reitingas, Adresas, Gatve, Namas, Butas)
VALUES 
    (1, 'Petraitis', '1995-05-12', 'Jonas', 2150, 'Vilnius', 'Gedimino pr.', '10', '5'),
    (2, 'Kazlauskas', '1998-08-23', 'Petras', 1850, 'Kaunas', 'Laisves al.', '25', '12'),
    (3, 'Jokubaitis', '1992-11-30', 'Mantas', 2300, 'Vilnius', 'Konstitucijos pr.', '7', '3'),
    (4, 'Vasiliauskas', '2000-03-15', 'Tomas', 1650, 'Klaipeda', 'Taikos pr.', '15', '8'),
    (5, 'Laurinavicius', '1996-07-08', 'Darius', 2050, 'Siauliai', 'Vilniaus g.', '30', '1'),
    (6, 'Butkus', '1994-02-18', 'Mindaugas', 2200, 'Vilnius', 'Ozo g.', '18', '45'),
    (7, 'Grigas', '1999-09-25', 'Lukas', 1720, 'Kaunas', 'Savanorių pr.', '120', '7'),
    (8, 'Zukauskas', '1997-12-03', 'Andrius', 1950, 'Klaipeda', 'Naujojo Sodo g.', '5', '22'),
    (9, 'Stonkus', '1993-06-14', 'Robertas', 2400, 'Vilnius', 'Kalvariju g.', '88', '15'),
    (10, 'Ramanauskas', '2001-04-20', 'Karolis', 1580, 'Panevezys', 'Respublikos g.', '42', '9');


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - PARTIJOS (20 įrašų)
-- ============================================================
INSERT INTO kisp0844.Partijos (ID, Varzybu_Id, LentosNr, Turas, Rezultatas)
VALUES 
    -- Varžybos #1 Vilnius
    (1, 1, 1, 1, '1-0'),
    (2, 1, 2, 1, '½-½'),
    (3, 1, 1, 2, '0-1'),
    (4, 1, 2, 2, '1-0'),
    -- Varžybos #2 Kaunas
    (5, 2, 1, 1, '1-0'),
    (6, 2, 2, 1, '½-½'),
    (7, 2, 1, 2, '0-1'),
    -- Varžybos #3 Klaipeda
    (8, 3, 1, 1, '0-1'),
    (9, 3, 2, 1, '1-0'),
    -- Varžybos #4 Siauliai
    (10, 4, 1, 1, '½-½'),
    (11, 4, 2, 1, '1-0'),
    -- Varžybos #5 Panevezys
    (12, 5, 1, 1, '1-0'),
    (13, 5, 2, 1, '0-1'),
    (14, 5, 1, 2, '½-½'),
    -- Varžybos #6 Alytus
    (15, 6, 1, 1, '1-0'),
    (16, 6, 1, 2, '0-1'),
    -- Varžybos #7 Marijampole
    (17, 7, 1, 1, '1-0'),
    (18, 7, 2, 1, '½-½'),
    (19, 7, 1, 2, '1-0'),
    (20, 7, 2, 2, '0-1');


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - ZAIDZIABALTAIS (20 įrašų)
-- ============================================================
INSERT INTO kisp0844.ZaidziaBaltais (PartijosID, ZaidejoId)
VALUES 
    (1, 1), (2, 2), (3, 3), (4, 6),
    (5, 1), (6, 3), (7, 9),
    (8, 4), (9, 8),
    (10, 5), (11, 2),
    (12, 6), (13, 10), (14, 1),
    (15, 7), (16, 4),
    (17, 9), (18, 3), (19, 6), (20, 1);


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - ZAIDZIAJUODAIS (20 įrašų)
-- ============================================================
INSERT INTO kisp0844.ZaidziaJuodais (PartijosID, ZaidejoId)
VALUES 
    (1, 2), (2, 3), (3, 1), (4, 2),
    (5, 5), (6, 2), (7, 3),
    (8, 1), (9, 4),
    (10, 7), (11, 5),
    (12, 3), (13, 9), (14, 6),
    (15, 8), (16, 7),
    (17, 2), (18, 6), (19, 9), (20, 3);


-- ============================================================
-- DUOMENŲ UŽPILDYMAS - PARASYTASATSILIEPIAMAS (15 įrašų)
-- ============================================================
INSERT INTO kisp0844.ParasytasAtsiliepiamas (ZaidejoId, VarzybuId)
VALUES 
    (1, 1), (2, 1), (3, 1), (6, 1),
    (1, 2), (2, 2), (3, 2), (5, 2), (9, 2),
    (1, 3), (4, 3), (8, 3),
    (2, 4), (5, 4), (7, 4);


-- ============================================================
-- MATERIALIZUOTOS VIEW ATNAUJINIMAS
-- ============================================================
REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;


-- ============================================================
-- PABAIGA - PRANEŠIMAS
-- ============================================================
\echo ''
\echo '======================================'
\echo 'DB SUKURTA SĖKMINGAI!'
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
