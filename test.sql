-- Create a small test competition with max 2 players
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('TestCity', '2025-01-01', 'Test', TRUE, 2, 5.0);

-- Capture the new competition ID
SELECT currval('kisp0844.Varžybos_VaržybųId_seq') AS test_competition_id;

INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES
(4, 1, 2, 1, 1, '1-0');

INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES
(4, 3, 4, 2, 1, '0-1');

-- This should raise:
-- ERROR: Pasiektas maksimalus žaidėjų kiekis varžybose
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (4, 5, 6, 3, 1, '1/2-1/2');

-- Should FAIL with CHK_SkirtingiŽaidėjai error
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 1, 1, 1, 1, '1-0');

-- Should FAIL
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 1, 2, 1, 99, 'WIN');

SELECT * FROM kisp0844.VaržybųPartijos WHERE VaržybųId = 1;

INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 9, 1, 9, 9, '1-0');

SELECT * FROM kisp0844.VaržybųPartijos WHERE VaržybųId = 1 ORDER BY LentosNr DESC;

-- Should FAIL because player ID 999 does not exist
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 999, 1, 5, 1, '1-0');

SELECT * FROM kisp0844.ŽaidėjųStatistika ORDER BY Pergalės DESC;

UPDATE kisp0844.Žaidėjai
SET ŽaidėjoId = 9999
WHERE ŽaidėjoId = 1;

UPDATE kisp0844.Partijos
SET JuodųŽaidėjuId= 9999
WHERE VaržybųId = 1 AND JuodųŽaidėjuId= 1;

-- 1) CHECK (Reitingas >= 0) on Žaidėjai
-- Should FAIL: negative rating not allowed
INSERT INTO kisp0844.Žaidėjai (Pavardė, GimimoData, Vardas, Reitingas, Gatvė, Butas, Namas)
VALUES ('Blogas', '2000-01-01', 'Minusas', -100, 'Test g.', '1', '1');

-- Should PASS: valid non-negative rating
INSERT INTO kisp0844.Žaidėjai (Pavardė, GimimoData, Vardas, Reitingas, Gatvė, Butas, Namas)
VALUES ('Gerulis', '2000-01-01', 'Nulis', 0, 'Test g.', '2', '2');

--------------------------------------------------------------
-- 2) CHECK (MaksimalusŽaidėjųKiekis > 0) on Varžybos
--------------------------------------------------------------

-- Should FAIL: max players cannot be 0
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('ZeroCity', '2025-02-01', 'Z', TRUE, 0, 5.00);

-- Should PASS: positive max players
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('OkCity', '2025-02-02', 'Z', TRUE, 4, 5.00);

--------------------------------------------------------------
-- 3) CHECK (Įvertinimas BETWEEN 0 AND 10) on Varžybos
--------------------------------------------------------------

-- Should FAIL: rating above 10
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('TooHighCity', '2025-03-01', 'R', TRUE, 4, 11.00);

-- Should FAIL: rating below 0
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('TooLowCity', '2025-03-02', 'R', TRUE, 4, -1.00);

-- Should PASS: rating within [0, 10]
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('JustRightCity', '2025-03-03', 'R', TRUE, 4, 9.50);

--------------------------------------------------------------
-- 4) CHECK Rezultatas IN (...) on Partijos
--------------------------------------------------------------

-- Should FAIL: invalid result code
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 1, 2, 99, 99, 'WIN');

-- Should PASS: valid result code '1/2-1/2'
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 1, 2, 100, 99, '1/2-1/2');

--------------------------------------------------------------
-- 5) CHK_SkirtingiŽaidėjai (JuodųŽaidėjuId <> BaltųŽaidėjuId)
--------------------------------------------------------------

-- Should FAIL: same player on both colors
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 2, 2, 200, 1, '1-0');

-- Should PASS: different players
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 2, 3, 201, 1, '1-0');

--------------------------------------------------------------
-- 6) Trigger: patikrinti_maksimalu_zaidejų_kieki()
--     check competition max players based on distinct participants
--------------------------------------------------------------

-- Create a small test competition with max 2 players
INSERT INTO kisp0844.Varžybos (Vieta, Data, Kategorija, ArReitinguojamas, MaksimalusŽaidėjųKiekis, Įvertinimas)
VALUES ('TriggerCity', '2025-04-01', 'T', TRUE, 2, 6.00);

-- Use the sequence to get its ID (assuming default sequence name pattern)
SELECT currval('kisp0844.\"Varžybos_VaržybųId_seq\"') AS trigger_test_competition_id;

-- For clarity, assume the new ID is X; below uses currval() to avoid hardcoding
-- First game: player 1 vs 2  (distinct players count = 2)
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (currval('kisp0844.\"Varžybos_VaržybųId_seq\"'), 1, 2, 1, 1, '1-0');

-- Second game: same two players, reversed colors (still 2 distinct players → should PASS)
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (currval('kisp0844.\"Varžybos_VaržybųId_seq\"'), 2, 1, 2, 1, '0-1');

-- Third game: introduces a new player 3 (distinct players would become 3 → should FAIL)
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (currval('kisp0844.\"Varžybos_VaržybųId_seq\"'), 3, 1, 3, 1, '1/2-1/2');

--------------------------------------------------------------
-- 7) Trigger: patikrinti_zaideju_egzistavima()
--     checks that player IDs exist in Žaidėjai
--------------------------------------------------------------

-- Should FAIL: player ID 999999 does not exist
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 999999, 2, 10, 1, '1-0');

-- Should FAIL: player ID 888888 does not exist (white)
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 2, 888888, 11, 1, '1-0');

-- Should PASS: both players exist
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 2, 3, 12, 1, '1-0');

--------------------------------------------------------------
-- 8) Trigger: refresh_varzybų_partijos()
--     verify that materialized view reflects new game
--------------------------------------------------------------

-- Insert a new valid game into existing competition 1
INSERT INTO kisp0844.Partijos (VaržybųId, JuodųŽaidėjuId, BaltųŽaidėjuId, LentosNr, Turas, Rezultatas)
VALUES (1, 3, 1, 13, 2, '0-1');

-- After this, the materialized view should contain this game
SELECT * FROM kisp0844.VaržybųPartijos
WHERE VaržybųId = 1
ORDER BY Data, BaltųPavardė, JuodųPavardė, Rezultatas;


