-- ============================================================
-- MINIMAL SCHEMA - 4 TABLES ONLY
-- ============================================================
CREATE SCHEMA IF NOT EXISTS kisp0844;


-- ============================================================
-- 4 PAGRINDINĖS LENTELĖS
-- ============================================================

-- Lentelė 1: varzybos
CREATE TABLE kisp0844.varzybos (
    varzybu_id INTEGER NOT NULL PRIMARY KEY,
    ar_reitinguojamas BOOLEAN NOT NULL,
    vieta VARCHAR(30) NOT NULL,
    data DATE DEFAULT CURRENT_DATE,
    kategorija VARCHAR(2) NOT NULL,
    maksimalus_zaideju_kiekis SMALLINT DEFAULT 0 NOT NULL,
    ivertinimas SMALLINT CHECK (ivertinimas BETWEEN 0 AND 100)
);

-- Lentelė 2: zaidejai
CREATE TABLE kisp0844.zaidejai (
    zaidejo_id INTEGER NOT NULL PRIMARY KEY,
    pavarde VARCHAR(30) NOT NULL,   
    gimimo_data DATE DEFAULT CURRENT_DATE,
    vardas VARCHAR(30) NOT NULL,
    reitingas SMALLINT DEFAULT 1000 CHECK (reitingas BETWEEN 1000 AND 3000),
    adresas VARCHAR(50) NOT NULL,
    gatve VARCHAR(30) NOT NULL,
    namas VARCHAR(10) NOT NULL,
    butas VARCHAR(10) NOT NULL
);

-- Lentelė 3: partijos (with direct player references)
CREATE TABLE kisp0844.partijos (
    id INTEGER NOT NULL PRIMARY KEY,
    varzybu_id INTEGER NOT NULL,
    juodu_zaidejo_id INTEGER NOT NULL,
    baltu_zaidejo_id INTEGER NOT NULL,
    lentos_nr SMALLINT NOT NULL,
    turas SMALLINT NOT NULL,
    rezultatas VARCHAR(10) NOT NULL,
    FOREIGN KEY (varzybu_id) REFERENCES kisp0844.varzybos(varzybu_id) ON DELETE CASCADE,
    FOREIGN KEY (juodu_zaidejo_id) REFERENCES kisp0844.zaidejai(zaidejo_id) ON DELETE CASCADE,
    FOREIGN KEY (baltu_zaidejo_id) REFERENCES kisp0844.zaidejai(zaidejo_id) ON DELETE CASCADE,
    CONSTRAINT chk_rezultatas CHECK (rezultatas IN ('1-0', '0-1', '½-½'))
);

-- Lentelė 4: parasytasatsiliepiamas (M:N ryšys)
CREATE TABLE kisp0844.parasytasatsiliepiamas (
    zaidejo_id INTEGER NOT NULL,
    varzybu_id INTEGER NOT NULL,
    PRIMARY KEY (zaidejo_id, varzybu_id),
    FOREIGN KEY (zaidejo_id) REFERENCES kisp0844.zaidejai(zaidejo_id) ON DELETE CASCADE,
    FOREIGN KEY (varzybu_id) REFERENCES kisp0844.varzybos(varzybu_id) ON DELETE CASCADE
);


-- ============================================================
-- INDEKSAI
-- ============================================================
CREATE UNIQUE INDEX idx_varzybos_vieta_data ON kisp0844.varzybos (vieta, data);
CREATE INDEX idx_zaidejai_pavarde ON kisp0844.zaidejai (pavarde);
CREATE INDEX idx_partijos_varzybu ON kisp0844.partijos (varzybu_id);


-- ============================================================
-- VIRTUALIOSIOS LENTELĖS
-- ============================================================

-- View #1: Varzybų partijos
CREATE VIEW kisp0844.varzybu_partijos AS
SELECT 
    v.varzybu_id,
    v.vieta AS varzybu_pavadinimas, 
    p.id AS partijos_id, 
    p.rezultatas
FROM kisp0844.varzybos v
JOIN kisp0844.partijos p ON v.varzybu_id = p.varzybu_id;

-- View #2: Sporto meistrai (reitingas > 2100)
CREATE VIEW kisp0844.sporto_meistrai AS
SELECT 
    z.zaidejo_id,
    z.pavarde,
    z.gimimo_data,
    z.vardas,
    z.reitingas
FROM kisp0844.zaidejai z
WHERE z.reitingas > 2100;


-- ============================================================
-- MATERIALIZUOTA VIRTUALIOJI LENTELĖ
-- ============================================================
CREATE MATERIALIZED VIEW kisp0844.vidutiniai_reitingai AS
SELECT 
    v.varzybu_id AS varzybu_id, 
    v.vieta AS pavadinimas, 
    ROUND(AVG(z.reitingas), 2) AS vidutinis_reitingas
FROM kisp0844.varzybos v
JOIN kisp0844.partijos p ON v.varzybu_id = p.varzybu_id
JOIN (
    -- Collect white players
    SELECT p.varzybu_id, z_balti.zaidejo_id, z_balti.reitingas
    FROM kisp0844.partijos p
    JOIN kisp0844.zaidejai z_balti ON p.baltu_zaidejo_id = z_balti.zaidejo_id

    UNION ALL

    -- Collect black players
    SELECT p.varzybu_id, z_juodi.zaidejo_id, z_juodi.reitingas
    FROM kisp0844.partijos p
    JOIN kisp0844.zaidejai z_juodi ON p.juodu_zaidejo_id = z_juodi.zaidejo_id
) z ON p.varzybu_id = z.varzybu_id
GROUP BY v.varzybu_id, v.vieta;


-- ============================================================
-- DALYKINĖS TAISYKLĖS - FUNKCIJOS IR TRIGERIAI
-- ============================================================

-- Funkcija #1: Automatinis žaidėjų kiekio atnaujinimas
CREATE OR REPLACE FUNCTION kisp0844.atnaujinti_zaideju_kieki()
RETURNS TRIGGER AS $$
BEGIN 
    UPDATE kisp0844.varzybos AS v
    SET maksimalus_zaideju_kiekis = (
        SELECT COUNT(DISTINCT zaidejo_id)
        FROM (
            SELECT baltu_zaidejo_id AS zaidejo_id
            FROM kisp0844.partijos
            WHERE varzybu_id = COALESCE(NEW.varzybu_id, OLD.varzybu_id)

            UNION

            SELECT juodu_zaidejo_id AS zaidejo_id
            FROM kisp0844.partijos
            WHERE varzybu_id = COALESCE(NEW.varzybu_id, OLD.varzybu_id)
        ) AS all_players
    )
    WHERE v.varzybu_id = COALESCE(NEW.varzybu_id, OLD.varzybu_id);
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_zaideju_kiekis
AFTER INSERT OR DELETE ON kisp0844.partijos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.atnaujinti_zaideju_kieki();


-- Funkcija #2: Unikalios varzybos (vieta + data)
CREATE OR REPLACE FUNCTION kisp0844.unikalios_varzybos()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM kisp0844.varzybos v
        WHERE v.vieta = NEW.vieta 
          AND v.data = NEW.data
          AND v.varzybu_id != NEW.varzybu_id
    )
    THEN 
        RAISE EXCEPTION 'Dvi varzybos negali vykti ten pat tuo pačiu laiku!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_ar_unikalios_varzybos
BEFORE INSERT OR UPDATE ON kisp0844.varzybos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.unikalios_varzybos();


-- Funkcija #3: Automatinis materializuotos lentelės atnaujinimas
CREATE OR REPLACE FUNCTION kisp0844.refresh_vidutiniai_reitingai()
RETURNS TRIGGER AS $$
BEGIN
    REFRESH MATERIALIZED VIEW kisp0844.vidutiniai_reitingai;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_avg_reitingas_zaidejai
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.zaidejai
FOR EACH ROW
EXECUTE FUNCTION kisp0844.refresh_vidutiniai_reitingai();

CREATE TRIGGER trigger_update_avg_reitingas_partijos
AFTER INSERT OR UPDATE OR DELETE ON kisp0844.partijos
FOR EACH ROW
EXECUTE FUNCTION kisp0844.refresh_vidutiniai_reitingai();
