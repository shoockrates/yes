--CREATE SCHEMA kisp0844;

-- Lentelė 1: Varzybos
CREATE TABLE kisp0844.Varzybos (
    VarzybuId INTEGER NOT NULL PRIMARY KEY,
    ArReitinguojamas BOOLEAN NOT NULL,
    Vieta VARCHAR(30) NOT NULL,
    Data DATE DEFAULT CURRENT_DATE,  -- Numatytoji reikšmė #1
    Kategorija VARCHAR(2) NOT NULL,
    MaksimalusZaidejusKiekis SMALLINT DEFAULT 0 NOT NULL,  -- Numatytoji reikšmė #2
    Ivertinimas SMALLINT CHECK (Ivertinimas BETWEEN 0 AND 100)  -- Reikalavimas reikšmėms #1
);


-- Lentelė 2: Zaidejai
CREATE TABLE kisp0844.Zaidejai (
    ZaidejoId INTEGER NOT NULL PRIMARY KEY,
    Pavarde VARCHAR(30) NOT NULL,   
    GimimoData DATE DEFAULT CURRENT_DATE,  -- Numatytoji reikšmė #3
    Vardas VARCHAR(30) NOT NULL,
    Reitingas SMALLINT DEFAULT 0 CHECK (Reitingas BETWEEN 1000 AND 2800),  -- Reikalavimas reikšmėms #2
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
    CONSTRAINT chk_rezultatas CHECK (Rezultatas IN ('1-0', '0-1', '½-½'))  -- Reikalavimas reikšmėms #3
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

-- Atnaujinimo sakinys
-- REFRESH MATERIALIZED VIEW kisp0844.VidutiniaiReitingai;

-- Dalykinė taisyklė #1: Automatinis žaidėjų kiekio atnaujinimas
CREATE OR REPLACE FUNCTION atnaujintiZaidejuKieki()
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
