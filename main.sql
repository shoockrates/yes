
CREATE SCHEMA kisp0844;

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
    VaržybųId           INTEGER  NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    Vieta               VARCHAR(100) NOT NULL,
    Data                DATE NOT NULL,
    Kategorija          VARCHAR(50) NOT NULL,
    ArReitinguojamas    BOOLEAN DEFAULT TRUE,
    MaksimalusŽaidėjųKiekis INTEGER CHECK (MaksimalusŽaidėjųKiekis > 0),
    Įvertinimas         DECIMAL(3, 2) CHECK (Įvertinimas >= 0 AND Įvertinimas <= 10)
);

-- Partijos (Games/Matches) table
CREATE TABLE kisp0844.Partijos (
    ID              INTEGER  NOT NULL PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    VaržybųId       INTEGER NOT NULL,
    JuodųŽaidėjuId  INTEGER NOT NULL,
    BaltųŽaidėjuId  INTEGER NOT NULL,
    LentosNr        INTEGER NOT NULL,
    Turas           INTEGER NOT NULL,
    Rezultatas      VARCHAR(10) CHECK (Rezultatas IN ('1-0', '0-1', '1/2-1/2', '0-0')),
    
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

-- ParašytasAtsiliepimaS (Reviews) junction table
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

-- Indexes
CREATE INDEX idx_varzybos_data ON kisp0844.Varžybos(Data);
CREATE INDEX idx_partijos_varzybos ON kisp0844.Partijos(VaržybųId);
CREATE INDEX idx_partijos_juodu ON kisp0844.Partijos(JuodųŽaidėjuId);
CREATE INDEX idx_partijos_baltu ON kisp0844.Partijos(BaltųŽaidėjuId);

-- Views
CREATE VIEW ŽaidėjųStatistika(ŽaidėjoId, Vardas, Pavardė, Pergalės, Pralaimėjimai, Lygiosios)
AS 
SELECT 
    ž.ŽaidėjoId,
    ž.Vardas,
    ž.Pavardė,
    SUM(CASE 
        WHEN (p.BaltųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '1-0') OR
             (p.JuodųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '0-1') 
        THEN 1 ELSE 0 END) AS Pergalės,
    SUM(CASE 
        WHEN (p.BaltųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '0-1') OR
             (p.JuodųŽaidėjuId = ž.ŽaidėjoId AND p.Rezultatas = '1-0') 
        THEN 1 ELSE 0 END) AS Pralaimėjimai,
    SUM(CASE WHEN p.Rezultatas = '1/2-1/2' THEN 1 ELSE 0 END) AS Lygiosios
FROM kisp0844.Žaidėjai ž
LEFT JOIN kisp0844.Partijos p 
    ON ž.ŽaidėjoId = p.BaltųŽaidėjuId OR ž.ŽaidėjoId = p.JuodųŽaidėjuId
GROUP BY ž.ŽaidėjoId, ž.Vardas, ž.Pavardė;

CREATE VIEW VaržybųDalyviai(VaržybųId, Vieta, Data, DalyviųSkaičiuS)
AS
SELECT 
    v.VaržybųId,
    v.Vieta,
    v.Data,
    COUNT(DISTINCT CASE WHEN p.BaltųŽaidėjuId IS NOT NULL THEN p.BaltųŽaidėjuId END) +
    COUNT(DISTINCT CASE WHEN p.JuodųŽaidėjuId IS NOT NULL THEN p.JuodųŽaidėjuId END) AS DalyviųSkaičiuS
FROM kisp0844.Varžybos v
LEFT JOIN kisp0844.Partijos p ON v.VaržybųId = p.VaržybųId
GROUP BY v.VaržybųId, v.Vieta, v.Data;

-- Triggers
CREATE OR REPLACE FUNCTION patikrinti_maksimalu_zaidejų_kieki()
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
EXECUTE FUNCTION patikrinti_maksimalu_zaidejų_kieki();
