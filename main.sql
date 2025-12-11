-- Žaidėjai (Players) table
CREATE TABLE kisp0844.Žaidėjai (
    ŽaidėjoId  INTEGER  NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Pavardė    VARCHAR(50) NOT NULL,
    GimimoData DATE NOT NULL,
    Vardas     VARCHAR(50) NOT NULL,
    Reitingas  INTEGER CHECK (Reitingas >= 0),
    Gatvė      VARCHAR(50),
    Butas      VARCHAR(10),
    Namas      VARCHAR(10)
);

-- Varžybos (Competitions) table
CREATE TABLE kisp0844.Varžybos (
    VaržybųId            INTEGER  NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Vieta                VARCHAR(100) NOT NULL,
    Data                 DATE NOT NULL,
    Kategorija           VARCHAR(50) NOT NULL,
    ArReitinguojamas     BOOLEAN DEFAULT TRUE,
    MaksimalusŽaidėjųKiekis INTEGER CHECK (MaksimalusŽaidėjųKiekis > 0),
    Įvertinimas          DECIMAL(3, 2) CHECK (Įvertinimas >= 0 AND Įvertinimas <= 10)
);

-- Partijos (Games)
CREATE TABLE kisp0844.Partijos (
    ID               INTEGER  NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    VaržybųId        INTEGER NOT NULL,
    JuodųŽaidėjuId   INTEGER NOT NULL,
    BaltųŽaidėjuId   INTEGER NOT NULL,
    LentosNr         INTEGER NOT NULL,
    Turas            INTEGER NOT NULL,
    Rezultatas       VARCHAR(10) CHECK (Rezultatas IN ('1-0', '0-1', '1/2-1/2', '0-0')),

    CONSTRAINT FK_Varžybos FOREIGN KEY(VaržybųId)
        REFERENCES kisp0844.Varžybos(VaržybųId)
        ON DELETE CASCADE ON UPDATE RESTRICT,

    CONSTRAINT FK_JuodųŽaidėjas FOREIGN KEY(JuodųŽaidėjuId)
        REFERENCES kisp0844.Žaidėjai(ŽaidėjoId)
        ON DELETE CASCADE ON UPDATE RESTRICT,

    CONSTRAINT FK_BaltųŽaidėjas FOREIGN KEY(BaltųŽaidėjuId)
        REFERENCES kisp0844.Žaidėjai(ŽaidėjoId)
        ON DELETE CASCADE ON UPDATE RESTRICT,

    CONSTRAINT CHK_SkirtingiŽaidėjai CHECK (JuodųŽaidėjuId <> BaltųŽaidėjuId)
);

-- ParašytasAtsiliepimas (Reviews)
CREATE TABLE kisp0844.ParašytasAtsiliepimaS (
    ŽaidėjoId   INTEGER NOT NULL,
    VaržybųId   INTEGER NOT NULL,

    PRIMARY KEY(ŽaidėjoId, VaržybųId),

    CONSTRAINT FK_Žaidėjas FOREIGN KEY(ŽaidėjoId)
        REFERENCES kisp0844.Žaidėjai(ŽaidėjoId)
        ON DELETE CASCADE ON UPDATE RESTRICT,

    CONSTRAINT FK_VaržybosAts FOREIGN KEY(VaržybųId)
        REFERENCES kisp0844.Varžybos(VaržybųId)
        ON DELETE CASCADE ON UPDATE RESTRICT
);

CREATE INDEX idx_varzybos_data   ON kisp0844.Varžybos(Data);
CREATE INDEX idx_partijos_varzybos ON kisp0844.Partijos(VaržybųId);
CREATE INDEX idx_partijos_juodu  ON kisp0844.Partijos(JuodųŽaidėjuId);
CREATE INDEX idx_partijos_baltu  ON kisp0844.Partijos(BaltųŽaidėjuId);

-- Žaidėjų statistikos vaizdas
CREATE VIEW kisp0844.ŽaidėjųStatistika AS 
SELECT 
    ž.ŽaidėjoId,
    ž.Vardas,
    ž.Pavardė,
    COALESCE(SUM(CASE 
        WHEN (p.BaltųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '1-0') OR
             (p.JuodųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '0-1')
        THEN 1 ELSE 0 END), 0) AS Pergalės,
    COALESCE(SUM(CASE 
        WHEN (p.BaltųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '0-1') OR
             (p.JuodųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '1-0')
        THEN 1 ELSE 0 END), 0) AS Pralaimėjimai,
    COALESCE(SUM(CASE WHEN p.Rezultatas = '1/2-1/2' THEN 1 ELSE 0 END), 0) AS Lygiosios
FROM kisp0844.Žaidėjai ž
LEFT JOIN kisp0844.Partijos p 
    ON ž.ŽaidėjoId = p.BaltųŽaidėjuId OR ž.ŽaidėjoId = p.JuodųŽaidėjuId
GROUP BY ž.ŽaidėjoId, ž.Vardas, ž.Pavardė;

-- Varžybų dalyvių skaičiaus vaizdas
CREATE VIEW kisp0844.VaržybųDalyviai AS
SELECT 
    v.VaržybųId,
    v.Vieta,
    v.Data,
    COUNT(DISTINCT COALESCE(p.BaltųŽaidėjuId, 0)) + 
    COUNT(DISTINCT COALESCE(p.JuodųŽaidėjuId, 0)) AS DalyviųSkaičius
FROM kisp0844.Varžybos v
LEFT JOIN kisp0844.Partijos p ON v.VaržybųId = p.VaržybųId
GROUP BY v.VaržybųId, v.Vieta, v.Data;

-- Materializuotas vaizdas varžybų partijoms
CREATE MATERIALIZED VIEW kisp0844.VaržybųPartijos AS
SELECT 
    v.VaržybųId,
    v.Vieta,
    v.Data,
    žb.Vardas  AS BaltųVardas,
    žb.Pavardė AS BaltųPavardė,
    žj.Vardas  AS JuodųVardas,
    žj.Pavardė AS JuodųPavardė,
    p.Rezultatas
FROM kisp0844.Varžybos v
JOIN kisp0844.Partijos p ON v.VaržybųId = p.VaržybųId
JOIN kisp0844.Žaidėjai žb ON p.BaltųŽaidėjuId = žb.ŽaidėjoId
JOIN kisp0844.Žaidėjai žj ON p.JuodųŽaidėjuId = žj.ŽaidėjoId;

--------------------------------------------------------------
-- Trigger: tikrinti maksimalų žaidėjų kiekį
--------------------------------------------------------------

CREATE OR REPLACE FUNCTION kisp0844.patikrinti_maksimalu_zaidejų_kieki()
RETURNS TRIGGER AS $$
DECLARE
    dalyviu_skaicius INTEGER;
    maksimalus_kiekis INTEGER;
BEGIN
    SELECT COUNT(DISTINCT player_id) INTO dalyviu_skaicius
    FROM (
        SELECT BaltųŽaidėjuId AS player_id FROM kisp0844.Partijos WHERE VaržybųId = NEW.VaržybųId
        UNION
        SELECT JuodųŽaidėjuId FROM kisp0844.Partijos WHERE VaržybųId = NEW.VaržybųId
    ) AS players;

    SELECT MaksimalusŽaidėjųKiekis INTO maksimalus_kiekis
    FROM kisp0844.Varžybos
    WHERE VaržybųId = NEW.VaržybųId;

    IF maksimalus_kiekis IS NOT NULL AND dalyviu_skaicius >= maksimalus_kiekis THEN
        RAISE EXCEPTION 'Pasiektas maksimalus žaidėjų kiekis varžybose';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tikrinti_dalyviu_kieki
BEFORE INSERT ON kisp0844.Partijos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.patikrinti_maksimalu_zaidejų_kieki();

--------------------------------------------------------------
-- NEW: trigger to report FK-style errors for players
--------------------------------------------------------------

CREATE OR REPLACE FUNCTION kisp0844.patikrinti_zaideju_egzistavima()
RETURNS TRIGGER AS $$
DECLARE
    cnt INTEGER;
BEGIN
    -- Tikriname juodųjų žaidėją
    IF NEW.JuodųŽaidėjuId IS NOT NULL THEN
        SELECT COUNT(*) INTO cnt
        FROM kisp0844.Žaidėjai
        WHERE ŽaidėjoId = NEW.JuodųŽaidėjuId;

        IF cnt = 0 THEN
            RAISE EXCEPTION 'JuodųŽaidėjuId % neegzistuoja Žaidėjai lentelėje', NEW.JuodųŽaidėjuId;
        END IF;
    END IF;

    -- Tikriname baltųjų žaidėją
    IF NEW.BaltųŽaidėjuId IS NOT NULL THEN
        SELECT COUNT(*) INTO cnt
        FROM kisp0844.Žaidėjai
        WHERE ŽaidėjoId = NEW.BaltųŽaidėjuId;

        IF cnt = 0 THEN
            RAISE EXCEPTION 'BaltųŽaidėjuId % neegzistuoja Žaidėjai lentelėje', NEW.BaltųŽaidėjuId;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tikrinti_partijos_zaidejus
BEFORE INSERT OR UPDATE OF JuodųŽaidėjuId, BaltųŽaidėjuId
ON kisp0844.Partijos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.patikrinti_zaideju_egzistavima();

--------------------------------------------------------------
-- Trigger: atnaujinti materializuotą vaizdą
--------------------------------------------------------------

CREATE OR REPLACE FUNCTION kisp0844.refresh_varzybų_partijos()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW kisp0844.VaržybųPartijos;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER refresh_varzybų_partijos_trigger
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.Partijos
FOR EACH STATEMENT
EXECUTE FUNCTION kisp0844.refresh_varzybų_partijos();

--------------------------------------------------------------
-- Pradiniai duomenys
--------------------------------------------------------------

INSERT INTO kisp0844.Žaidėjai (Pavardė, GimimoData, Vardas, Reitingas, Gatvė, Butas, Namas) VALUES
('Petrauskas',   '1990-05-12', 'Jonas',   2100, 'Ąžuolų g.', '5',  '12A'),
('Kazlauskienė', '1985-11-23', 'Austėja', 1950, 'Beržų g.',  '12', '7B'),
('Jankauskas',   '2001-02-03', 'Mantas',  1800, 'Taikos pr.', NULL,'45'),
('Mockus',       '1995-07-08', 'Lukas',   2200, 'Žalgirio g.','22','9'),
('Paulauskas',   '1988-09-14', 'Darius',  1600, 'Sodų g.',   NULL,'3'),
('Šimkutė',      '2003-03-18', 'Gabija',  2000, 'Pievų g.',  '2', '14'),
('Kvedaras',     '1999-01-27', 'Rokas',   1500, 'Šilo g.',   '11','6'),
('Butkutė',      '1992-04-10', 'Ieva',    1750, 'Vyšnių g.', NULL,'24'),
('Vasiliauskas', '1980-12-02', 'Tomas',   2300, 'Jūros g.',  '7', '18'),
('Kučinskas',    '1997-08-29', 'Paulius', 1900, 'Parko g.',  '15','10');

INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas) VALUES
('Vilnius',  '2024-02-10', 'A', TRUE, 10, 8.50),
('Kaunas',   '2024-03-05', 'B', TRUE, 8,  7.20),
('Klaipėda', '2024-04-12', 'C', FALSE,12, 9.10);

INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas) VALUES
(1, 1,  2,  1, 1, '1-0'),
(1, 3,  4,  2, 1, '1/2-1/2'),
(1, 5,  6,  3, 1, '0-1'),
(1, 7,  8,  1, 2, '1-0'),
(1, 9, 10,  2, 2, '1/2-1/2');

INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas) VALUES
(2, 4, 1, 1, 1, '0-1'),
(2, 6, 3, 2, 1, '1-0'),
(2, 2, 5, 1, 2, '1/2-1/2'),
(2, 8, 7, 2, 2, '1-0');

INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas) VALUES
(3, 10, 9, 1, 1, '0-1'),
(3, 1,  6, 2, 1, '1-0'),
(3, 3,  2, 3, 1, '1/2-1/2'),
(3, 7,  4, 1, 2, '0-1'),
(3, 5,  8, 2, 2, '1-0');

INSERT INTO kisp0844.ParašytasAtsiliepimaS (ŽaidėjoId, VaržybųId) VALUES
(1, 1),
(2, 1),
(4, 2),
(6, 2),
(9, 3),
(10, 3);


