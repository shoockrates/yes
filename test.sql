-- ============================================================================
-- TESTINIAI SQL SAKINIAI DALYKINĖMS TAISYKLĖMS - kisp0844 Schema
-- ============================================================================

-- ============================================================================
-- TESTAS 1: CHECK APRIBOJIMAI (Reikalavimas reikšmėms)
-- ============================================================================

RAISE NOTICE '=== TESTAS 1: CHECK Apribojimai ===';

-- Testas 1.1: Teisingas varžybų įvertinimas (0-100) - TURĖTŲ PAVYKTI
INSERT INTO kisp0844.Varzybos VALUES (10, TRUE, 'Testas Miestas', '2025-12-15', 'GM', 0, 50);
SELECT 'Testas 1.1 PAVYKO: Teisingas įvertinimas priimtas' AS rezultatas;
DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 10;

-- Testas 1.2: Neteisingas varžybų įvertinimas (>100) - TURĖTŲ NEPAVYKTI
DO $$
BEGIN
    INSERT INTO kisp0844.Varzybos VALUES (10, TRUE, 'Testas Miestas', '2025-12-15', 'GM', 0, 150);
    RAISE NOTICE 'Testas 1.2 NEPAVYKO: Neteisingas įvertinimas buvo priimtas!';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Testas 1.2 PAVYKO: Neteisingas įvertinimas atmestas (>100)';
END $$;

-- Testas 1.3: Teisingas žaidėjo reitingas (1000-2800) - TURĖTŲ PAVYKTI
INSERT INTO kisp0844.Zaidejai VALUES (10, 'Testas', '2000-01-01', 'Žaidėjas', 2000, 'Testas', 'Gatvė', '1', '1');
SELECT 'Testas 1.3 PAVYKO: Teisingas žaidėjo reitingas priimtas' AS rezultatas;
DELETE FROM kisp0844.Zaidejai WHERE ZaidejoId = 10;

-- Testas 1.4: Neteisingas žaidėjo reitingas (<1000) - TURĖTŲ NEPAVYKTI
DO $$
BEGIN
    INSERT INTO kisp0844.Zaidejai VALUES (10, 'Testas', '2000-01-01', 'Žaidėjas', 500, 'Testas', 'Gatvė', '1', '1');
    RAISE NOTICE 'Testas 1.4 NEPAVYKO: Neteisingas reitingas buvo priimtas!';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Testas 1.4 PAVYKO: Neteisingas reitingas atmestas (<1000)';
END $$;

-- Testas 1.5: Teisingas partijos rezultatas - TURĖTŲ PAVYKTI
INSERT INTO kisp0844.Partijos VALUES (10, 1, 5, 2, '½-½');
SELECT 'Testas 1.5 PAVYKO: Teisingas rezultatas priimtas' AS rezultatas;
DELETE FROM kisp0844.Partijos WHERE ID = 10;

-- Testas 1.6: Neteisingas partijos rezultatas - TURĖTŲ NEPAVYKTI
DO $$
BEGIN
    INSERT INTO kisp0844.Partijos VALUES (10, 1, 5, 2, '2-0');
    RAISE NOTICE 'Testas 1.6 NEPAVYKO: Neteisingas rezultatas buvo priimtas!';
EXCEPTION WHEN check_violation THEN
    RAISE NOTICE 'Testas 1.6 PAVYKO: Neteisingas rezultatas atmestas (2-0)';
END $$;


-- ============================================================================
-- TESTAS 2: DALYKINĖ TAISYKLĖ #1 - Automatinis žaidėjų kiekio atnaujinimas
-- ============================================================================

RAISE NOTICE '=== TESTAS 2: Dalykinė Taisyklė #1 (Automatinis MaksimalusZaidejusKiekis atnaujinimas) ===';

-- Testas 2.1: Patikrinti pradinį žaidėjų skaičių 1-oms varžyboms
SELECT VarzybuId, Vieta, MaksimalusZaidejusKiekis 
FROM kisp0844.Varzybos 
WHERE VarzybuId = 1;
-- Tikimasi: Turėtų parodyti unikalių žaidėjų skaičių

-- Testas 2.2: Įterpti naują partiją - skaičius turėtų padidėti
INSERT INTO kisp0844.Partijos VALUES (5, 1, 3, 2, '1-0');
INSERT INTO kisp0844.ZaidziaBaltais VALUES (5, 4);  -- Žaidžia vienas žaidėjas
INSERT INTO kisp0844.ZaidziaJuodais VALUES (5, 5);  -- Žaidžia kitas žaidėjas

SELECT VarzybuId, Vieta, MaksimalusZaidejusKiekis 
FROM kisp0844.Varzybos 
WHERE VarzybuId = 1;
-- Tikimasi: Skaičius turėtų padidėti
RAISE NOTICE 'Testas 2.2: Patikrinti ar žaidėjų skaičius padidėjo po INSERT';

-- Testas 2.3: Ištrinti partiją - skaičius turėtų sumažėti
DELETE FROM kisp0844.Partijos WHERE ID = 5;

SELECT VarzybuId, Vieta, MaksimalusZaidejusKiekis 
FROM kisp0844.Varzybos 
WHERE VarzybuId = 1;
-- Tikimasi: Skaičius turėtų grįžti į pradinę reikšmę
RAISE NOTICE 'Testas 2.3: Patikrinti ar žaidėjų skaičius sumažėjo po DELETE';


-- ============================================================================
-- TESTAS 3: DALYKINĖ TAISYKLĖ #2 - Unikalios varžybos (vieta + data)
-- ============================================================================

RAISE NOTICE '=== TESTAS 3: Dalykinė Taisyklė #2 (Unikalios varžybos) ===';

-- Testas 3.1: Bandyti įterpti varžybas toje pačioje vietoje ir tą pačią dieną - TURĖTŲ NEPAVYKTI
DO $$
BEGIN
    INSERT INTO kisp0844.Varzybos VALUES (10, TRUE, 'Vilnius', '2025-12-01', 'IM', 0, 80);
    RAISE NOTICE 'Testas 3.1 NEPAVYKO: Dubliuotos varžybos buvo priimtos!';
EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'Testas 3.1 PAVYKO: Dubliuotos varžybos atmestos';
END $$;

-- Testas 3.2: Įterpti varžybas toje pačioje vietoje bet skirtingą dieną - TURĖTŲ PAVYKTI
INSERT INTO kisp0844.Varzybos VALUES (10, TRUE, 'Vilnius', '2025-12-20', 'IM', 0, 80);
SELECT 'Testas 3.2 PAVYKO: Ta pati vieta, skirtinga data priimta' AS rezultatas;
DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 10;

-- Testas 3.3: Įterpti varžybas skirtingoje vietoje bet tą pačią dieną - TURĖTŲ PAVYKTI
INSERT INTO kisp0844.Varzybos VALUES (10, TRUE, 'Šiauliai', '2025-12-01', 'IM', 0, 80);
SELECT 'Testas 3.3 PAVYKO: Skirtinga vieta, ta pati data priimta' AS rezultatas;
DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 10;

-- Testas 3.4: Bandyti atnaujinti į dubliuotą vieta+data - TURĖTŲ NEPAVYKTI
DO $$
BEGIN
    UPDATE kisp0844.Varzybos 
    SET Vieta = 'Vilnius', Data = '2025-12-01' 
    WHERE VarzybuId = 2;
    RAISE NOTICE 'Testas 3.4 NEPAVYKO: UPDATE į dublikatą buvo priimtas!';
EXCEPTION WHEN raise_exception THEN
    RAISE NOTICE 'Testas 3.4 PAVYKO: UPDATE į dublikatą atmestas';
END $$;


-- ============================================================================
-- TESTAS 4: DALYKINĖ TAISYKLĖ #3 - Automatinis materializuoto vaizdo atnaujinimas
-- ============================================================================

RAISE NOTICE '=== TESTAS 4: Dalykinė Taisyklė #3 (Automatinis VidutiniaiReitingai atnaujinimas) ===';

-- Testas 4.1: Patikrinti dabartinius vidutinius reitingus
SELECT * FROM kisp0844.VidutiniaiReitingai ORDER BY VarzybuID;

-- Testas 4.2: Įterpti naują žaidėją su aukštu reitingu - vaizdas turėtų atsinaujinti
INSERT INTO kisp0844.Zaidejai VALUES (6, 'Pavardenis', '1992-07-30', 'Vardenis', 2800, 'Lietuva', 'Gatvė', '1', '1');
INSERT INTO kisp0844.Partijos VALUES (6, 1, 4, 2, '1-0');
INSERT INTO kisp0844.ZaidziaBaltais VALUES (6, 6);
INSERT INTO kisp0844.ZaidziaJuodais VALUES (6, 5);

SELECT * FROM kisp0844.VidutiniaiReitingai WHERE VarzybuID = 1;
-- Tikimasi: Vidurkis turėtų būti didesnis (pridėtas 2800 reitingo žaidėjas)
RAISE NOTICE 'Testas 4.2: Patikrinti ar materializuotas vaizdas atsinaujino po žaidėjo INSERT';

-- Testas 4.3: Atnaujinti žaidėjo reitingą - vaizdas turėtų atsinaujinti
UPDATE kisp0844.Zaidejai SET Reitingas = 1500 WHERE ZaidejoId = 5;

SELECT * FROM kisp0844.VidutiniaiReitingai WHERE VarzybuID = 1;
-- Tikimasi: Vidurkis turėtų pasikeisti (reitingas padidintas nuo 1200 iki 1500)
RAISE NOTICE 'Testas 4.3: Patikrinti ar materializuotas vaizdas atsinaujino po reitingo UPDATE';

-- Testas 4.4: Ištrinti partiją - vaizdas turėtų atsinaujinti
DELETE FROM kisp0844.Partijos WHERE ID = 6;

SELECT * FROM kisp0844.VidutiniaiReitingai WHERE VarzybuID = 1;
-- Tikimasi: Vidurkis turėtų pasikeisti (pašalintas aukšto reitingo žaidėjas)
RAISE NOTICE 'Testas 4.4: Patikrinti ar materializuotas vaizdas atsinaujino po partijos DELETE';

-- Išvalyti testinius duomenis
UPDATE kisp0844.Zaidejai SET Reitingas = 1200 WHERE ZaidejoId = 5;
DELETE FROM kisp0844.Zaidejai WHERE ZaidejoId = 6;


-- ============================================================================
-- TESTAS 5: NUMATYTOSIOS REIKŠMĖS (DEFAULT)
-- ============================================================================

RAISE NOTICE '=== TESTAS 5: Numatytosios reikšmės (DEFAULT) ===';

-- Testas 5.1: Varžybų data pagal nutylėjimą CURRENT_DATE
INSERT INTO kisp0844.Varzybos (VarzybuId, ArReitinguojamas, Vieta, Kategorija, Ivertinimas) 
VALUES (20, TRUE, 'Panevėžys', 'GM', 70);

SELECT VarzybuId, Data, Data = CURRENT_DATE AS ar_siandien 
FROM kisp0844.Varzybos 
WHERE VarzybuId = 20;
-- Tikimasi: ar_siandien turėtų būti TRUE
RAISE NOTICE 'Testas 5.1: Patikrinti ar varžybų data pagal nutylėjimą yra šiandiena';

DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 20;

-- Testas 5.2: MaksimalusZaidejusKiekis pagal nutylėjimą 0
INSERT INTO kisp0844.Varzybos (VarzybuId, ArReitinguojamas, Vieta, Data, Kategorija, Ivertinimas) 
VALUES (20, TRUE, 'Panevėžys', '2025-12-25', 'GM', 70);

SELECT VarzybuId, MaksimalusZaidejusKiekis 
FROM kisp0844.Varzybos 
WHERE VarzybuId = 20;
-- Tikimasi: MaksimalusZaidejusKiekis = 0
RAISE NOTICE 'Testas 5.2: Patikrinti ar žaidėjų skaičius pagal nutylėjimą yra 0';

DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 20;

-- Testas 5.3: Žaidėjo gimimo data pagal nutylėjimą CURRENT_DATE
INSERT INTO kisp0844.Zaidejai (ZaidejoId, Pavarde, Vardas, Reitingas, Adresas, Gatve, Namas, Butas) 
VALUES (20, 'Testas', 'Žaidėjas', 2000, 'Testas', 'Gatvė', '1', '1');

SELECT ZaidejoId, GimimoData, GimimoData = CURRENT_DATE AS ar_siandien 
FROM kisp0844.Zaidejai 
WHERE ZaidejoId = 20;
-- Tikimasi: ar_siandien turėtų būti TRUE
RAISE NOTICE 'Testas 5.3: Patikrinti ar gimimo data pagal nutylėjimą yra šiandiena';

DELETE FROM kisp0844.Zaidejai WHERE ZaidejoId = 20;


-- ============================================================================
-- TESTAS 6: UŽSIENIO RAKTAS SU CASCADE DELETE
-- ============================================================================

RAISE NOTICE '=== TESTAS 6: Užsienio raktas su CASCADE DELETE ===';

-- Testas 6.1: Ištrinti varžybas - visos susijusios partijos turėtų būti ištrintos
INSERT INTO kisp0844.Varzybos VALUES (30, TRUE, 'Testas Miestas', '2025-12-30', 'GM', 0, 80);
INSERT INTO kisp0844.Partijos VALUES (30, 30, 1, 1, '1-0');

DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 30;

SELECT COUNT(*) AS naslaites_partijos 
FROM kisp0844.Partijos 
WHERE Varzybu_Id = 30;
-- Tikimasi: 0 (partija turėtų būti automatiškai ištrinta)
RAISE NOTICE 'Testas 6.1: Patikrinti ar partijos ištrintos kai varžybos ištrintos';

-- Testas 6.2: Ištrinti žaidėją - visi susiję partijų priskyrimai turėtų būti ištrinti
INSERT INTO kisp0844.Zaidejai VALUES (30, 'Testas', '2000-01-01', 'Trynimas', 2000, 'Testas', 'Gat', '1', '1');
INSERT INTO kisp0844.Varzybos VALUES (31, TRUE, 'Testas Miestas 2', '2025-12-31', 'GM', 0, 80);
INSERT INTO kisp0844.Partijos VALUES (31, 31, 1, 1, '1-0');
INSERT INTO kisp0844.ZaidziaBaltais VALUES (31, 30);

DELETE FROM kisp0844.Zaidejai WHERE ZaidejoId = 30;

SELECT COUNT(*) AS naslaiciai_priskyrimai 
FROM kisp0844.ZaidziaBaltais 
WHERE ZaidejoId = 30;
-- Tikimasi: 0 (priskyrimas turėtų būti automatiškai ištrintas)
RAISE NOTICE 'Testas 6.2: Patikrinti ar partijų priskyrimai ištrinti kai žaidėjas ištrintas';

DELETE FROM kisp0844.Varzybos WHERE VarzybuId = 31;


-- ============================================================================
-- TESTAS 7: VAIZDAI IR INDEKSAI
-- ============================================================================

RAISE NOTICE '=== TESTAS 7: Vaizdai ir indeksai ===';

-- Testas 7.1: Paprastas vaizdas VarzybuPartijos
SELECT * FROM kisp0844.VarzybuPartijos WHERE VarzybuId = 1;
RAISE NOTICE 'Testas 7.1: VarzybuPartijos vaizdas veikia';

-- Testas 7.2: Paprastas vaizdas SportoMeistrai (reitingas > 2100)
SELECT * FROM kisp0844.SportoMeistrai ORDER BY Reitingas DESC;
RAISE NOTICE 'Testas 7.2: SportoMeistrai vaizdas rodo aukšto reitingo žaidėjus';

-- Testas 7.3: Materializuotas vaizdas VidutiniaiReitingai
SELECT * FROM kisp0844.VidutiniaiReitingai ORDER BY VarzybuID;
RAISE NOTICE 'Testas 7.3: VidutiniaiReitingai materializuotas vaizdas veikia';

-- Testas 7.4: Unikalus indeksas neleidžia dublikatų (Vieta, Data)
DO $$
BEGIN
    INSERT INTO kisp0844.Varzybos VALUES (40, TRUE, 'Kaunas', '2025-12-05', 'GM', 0, 85);
    RAISE NOTICE 'Testas 7.4 NEPAVYKO: Unikalus indeksas nesuveikė!';
EXCEPTION WHEN unique_violation THEN
    RAISE NOTICE 'Testas 7.4 PAVYKO: Unikalus indeksas užkirto kelią dublikatui vieta+data';
END $$;


-- ============================================================================
-- SANTRAUKA
-- ============================================================================

RAISE NOTICE '==========================================================';
RAISE NOTICE 'VISI TESTAI UŽBAIGTI';
RAISE NOTICE 'Peržiūrėkite rezultatus aukščiau, kad patvirtintumėte, jog visos taisyklės veikia';
RAISE NOTICE '==========================================================';
