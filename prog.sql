--CREATE SCHEMA kisp0844;

-- 1. Varzybos
CREATE TABLE kisp0844.Varzybos (
    VarzybuId INTEGER NOT NULL PRIMARY KEY,
    ArReitinguojamas BOOLEAN NOT NULL,
    Vieta VARCHAR(30) NOT NULL,
    Data DATE DEFAULT CURRENT_DATE,
    Kategorija VARCHAR(2) NOT NULL,
    MaksimalusZaidejusKiekis SMALLINT DEFAULT 0 NOT NULL,
    Ivertinimas SMALLINT CHECK (Ivertinimas BETWEEN 0 AND 100)
);

-- 2. Zaidejai
CREATE TABLE kisp0844.Zaidejai (
    ZaidejoId INTEGER NOT NULL PRIMARY KEY,
    Pavarde VARCHAR(30) NOT NULL,
    GimimoData DATE DEFAULT CURRENT_DATE,
    Vardas VARCHAR(30) NOT NULL,
    Reitingas SMALLINT DEFAULT 1000 CHECK (Reitingas BETWEEN 1000 AND 3000),
    Adresas VARCHAR(50) NOT NULL,
    Gatve VARCHAR(30) NOT NULL,
    Namas VARCHAR(10) NOT NULL,
    Butas VARCHAR(10) NOT NULL
);

-- 3. Partijos  (white/black directly here; no ZaidziaBaltais/ZaidziaJuodais tables)
CREATE TABLE kisp0844.Partijos (
    ID INTEGER NOT NULL PRIMARY KEY,
    Varzybu_Id INTEGER NOT NULL,
    JuoduZaidejoId INTEGER NOT NULL,
    BaltuZaidejoId INTEGER NOT NULL,
    LentosNr SMALLINT NOT NULL,
    Turas SMALLINT NOT NULL,
    Rezultatas VARCHAR(10) NOT NULL,
    FOREIGN KEY (Varzybu_Id)     REFERENCES kisp0844.Varzybos(VarzybuId) ON DELETE CASCADE,
    FOREIGN KEY (JuoduZaidejoId) REFERENCES kisp0844.Zaidejai(ZaidejoId)  ON DELETE CASCADE,
    FOREIGN KEY (BaltuZaidejoId) REFERENCES kisp0844.Zaidejai(ZaidejoId)  ON DELETE CASCADE,
    CONSTRAINT chk_rezultatas CHECK (Rezultatas IN ('1-0', '0-1', '½-½'))
);

-- 4. ParasytasAtsiliepiamas (M:N tarp Zaidejai ir Varzybos)
CREATE TABLE kisp0844.ParasytasAtsiliepiamas (
    ZaidejoId INTEGER NOT NULL,
    VarzybuId INTEGER NOT NULL,
    PRIMARY KEY (ZaidejoId, VarzybuId),
    FOREIGN KEY (ZaidejoId) REFERENCES kisp0844.Zaidejai(ZaidejoId) ON DELETE CASCADE,
    FOREIGN KEY (VarzybuId)  REFERENCES kisp0844.Varzybos(VarzybuId)  ON DELETE CASCADE
);


CREATE UNIQUE INDEX idx_varzybos_vieta_data ON kisp0844.Varzybos (Vieta, Data);  -- Unikalus indeksas
CREATE INDEX idx_zaidejai_pavarde ON kisp0844.Zaidejai (Pavarde);  -- Neunikalus indeksas
CREATE INDEX idx_partijos_varzybu ON kisp0844.Partijos (Varzybu_Id);  -- Neunikalus indeksas #2


-- Virtualioji lentelė #1: Varzybų partijos
CREATE VIEW kisp0844.VarzybuPartijos AS
SELECT 
    V.VarzybuId,
    V.Vieta AS VarzybuPavadinimas, 
    P.ID AS PartijosID, 
    P.Rezultatas
FROM kisp0844.Varzybos V
JOIN kisp0844.Partijos P ON V.VarzybuId = P.Varzybu_Id;


-- Virtualioji lentelė #2: Sport meistrai (reitingas > 2100)
CREATE VIEW kisp0844.SportoMeistrai AS
SELECT 
    Zaidejai.ZaidejoId,
    Zaidejai.Pavarde,
    Zaidejai.GimimoData,
    Zaidejai.Vardas,
    Zaidejai.Reitingas
FROM kisp0844.Zaidejai
WHERE Zaidejai.Reitingas > 2100;


-- ✅ FIXED: Materializuota lentelė dabar naudoja tikras lenteles
CREATE MATERIALIZED VIEW kisp0844.VidutiniaiReitingai AS
SELECT 
    V.VarzybuId AS VarzybuID, 
    V.Vieta AS Pavadinimas, 
    ROUND(AVG(Z.Reitingas), 2) AS VidutinisReitingas
FROM kisp0844.Varzybos V
JOIN kisp0844.Partijos P ON V.VarzybuId = P.Varzybu_Id
JOIN (
    -- Collect all players (white and black) from each game
    SELECT P.Varzybu_Id, ZBalti.ZaidejoId, ZBalti.Reitingas
    FROM kisp0844.Partijos P
    JOIN kisp0844.Zaidejai ZBalti ON P.BaltuZaidejoId = ZBalti.ZaidejoId
    
    UNION ALL
    
    SELECT P.Varzybu_Id, ZJuodi.ZaidejoId, ZJuodi.Reitingas
    FROM kisp0844.Partijos P
    JOIN kisp0844.Zaidejai ZJuodi ON P.JuoduZaidejoId = ZJuodi.ZaidejoId
) Z ON P.Varzybu_Id = Z.Varzybu_Id
GROUP BY V.VarzybuId, V.Vieta;

-- Atnaujinimo sakinys
-- REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;

-- ✅ FIXED: Dalykinė taisyklė #1 dabar skaičiuoja iš Partijos lentelės
CREATE OR REPLACE FUNCTION atnaujintiZaidejuKieki()
RETURNS TRIGGER AS $$
BEGIN 
    UPDATE kisp0844.Varzybos AS V
    SET MaksimalusZaidejusKiekis = (
        SELECT COUNT(DISTINCT ZaidejoId)
        FROM (
            SELECT BaltuZaidejoId AS ZaidejoId
            FROM kisp0844.Partijos
            WHERE Varzybu_Id = COALESCE(NEW.Varzybu_Id, OLD.Varzybu_Id)
            
            UNION
            
            SELECT JuoduZaidejoId AS ZaidejoId
            FROM kisp0844.Partijos
            WHERE Varzybu_Id = COALESCE(NEW.Varzybu_Id, OLD.Varzybu_Id)
        ) AS AllPlayers
    )
    WHERE V.VarzybuId = COALESCE(NEW.Varzybu_Id, OLD.Varzybu_Id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_zaideju_kiekis
AFTER INSERT OR DELETE ON kisp0844.Partijos
FOR EACH ROW
EXECUTE FUNCTION atnaujintiZaidejuKieki();


-- Dalykinė taisyklė #2: Unikalios varzybos (vieta + data)
CREATE OR REPLACE FUNCTION unikalios_varzybos()
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

CREATE TRIGGER trigger_ar_unikalios_varzybos
BEFORE INSERT OR UPDATE ON kisp0844.Varzybos
FOR EACH ROW
EXECUTE FUNCTION unikalios_varzybos();


-- Dalykinė taisyklė #3: Automatinis materializuotos lentelės atnaujinimas
CREATE OR REPLACE FUNCTION refresh_VidutiniaiReitingai()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_avg_reitingas_zaidejai
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.Zaidejai
FOR EACH ROW
EXECUTE FUNCTION refresh_VidutiniaiReitingai();

CREATE TRIGGER trigger_update_avg_reitingas_partijos
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.Partijos
FOR EACH ROW
EXECUTE FUNCTION refresh_VidutiniaiReitingai();
