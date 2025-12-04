-- 1. VARZYBOS (neturi FK)
INSERT INTO kisp0844.Varzybos (VarzybuId, ArReitinguojamas, Vieta, Data, Kategorija, MaksimalusZaidejusKiekis, Ivertinimas)
VALUES 
    (1, TRUE, 'Vilnius', '2024-01-15', 'A', 0, 85),
    (2, TRUE, 'Kaunas', '2024-02-20', 'B', 0, 90),
    (3, FALSE, 'Klaipeda', '2024-03-10', 'C', 0, 75),
    (4, TRUE, 'Siauliai', '2024-04-05', 'A', 0, 88);


-- 2. ZAIDEJAI (neturi FK)
INSERT INTO kisp0844.Zaidejai (ZaidejoId, Pavarde, GimimoData, Vardas, Reitingas, Adresas, Gatve, Namas, Butas)
VALUES 
    (1, 'Petraitis', '1995-05-12', 'Jonas', 2150, 'Vilnius', 'Gedimino pr.', '10', '5'),
    (2, 'Kazlauskas', '1998-08-23', 'Petras', 1850, 'Kaunas', 'Laisves al.', '25', '12'),
    (3, 'Jokubaitis', '1992-11-30', 'Mantas', 2300, 'Vilnius', 'Konstitucijos pr.', '7', '3'),
    (4, 'Vasiliauskas', '2000-03-15', 'Tomas', 1650, 'Klaipeda', 'Taikos pr.', '15', '8'),
    (5, 'Laurinavicius', '1996-07-08', 'Darius', 2050, 'Siauliai', 'Vilniaus g.', '30', '1');


-- 3. PARTIJOS (turi FK -> Varzybos)
INSERT INTO kisp0844.Partijos (ID, Varzybu_Id, LentosNr, Turas, Rezultatas)
VALUES 
    (1, 1, 1, 1, '1-0'),
    (2, 1, 2, 1, '½-½'),
    (3, 1, 1, 2, '0-1'),
    (4, 2, 1, 1, '1-0'),
    (5, 2, 2, 1, '½-½'),
    (6, 3, 1, 1, '0-1');


-- 4. ZAIDZIABALTAIS (turi FK -> Partijos, Zaidejai)
INSERT INTO kisp0844.ZaidziaBaltais (PartijosID, ZaidejoId)
VALUES 
    (1, 1),  -- Jonas Petraitis zaide baltais partijoje 1
    (2, 2),  -- Petras Kazlauskas zaide baltais partijoje 2
    (3, 3),  -- Mantas Jokubaitis zaide baltais partijoje 3
    (4, 1),
    (5, 3),
    (6, 4);


-- 5. ZAIDZIAJUODAIS (turi FK -> Partijos, Zaidejai)
INSERT INTO kisp0844.ZaidziaJuodais (PartijosID, ZaidejoId)
VALUES 
    (1, 2),  -- Petras Kazlauskas zaide juodais partijoje 1
    (2, 3),  -- Mantas Jokubaitis zaide juodais partijoje 2
    (3, 1),  -- Jonas Petraitis zaide juodais partijoje 3
    (4, 5),
    (5, 2),
    (6, 1);


-- 6. PARASYTASATSILIEPIAMAS (M:N tarp Zaidejai ir Varzybos)
INSERT INTO kisp0844.ParasytasAtsiliepiamas (ZaidejoId, VarzybuId)
VALUES 
    (1, 1),
    (2, 1),
    (3, 2),
    (4, 3),
    (5, 2);
