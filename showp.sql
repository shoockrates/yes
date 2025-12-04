\echo ''
\echo '========== VISI ŽAIDĖJAI =========='
SELECT ZaidejoId, Vardas || ' ' || Pavarde AS "Vardas", Reitingas 
FROM kisp0844.Zaidejai 
ORDER BY Reitingas DESC;

\echo ''
\echo '========== SPORTO MEISTRAI (>2100) =========='
SELECT COUNT(*) AS "Kiekis" FROM kisp0844.SportoMeistrai;

\echo ''
\echo '========== VARŽYBŲ DALYVIAI =========='
SELECT Varzybos, COUNT(DISTINCT ZaidejoId) AS "Dalyvių"
FROM kisp0844.VarzybuDalyviai
GROUP BY Varzybos, VarzybuId
ORDER BY VarzybuId;

\echo ''
\echo '========== TOP MATCHUPS =========='
SELECT 
    ZB.Vardas || ' ' || ZB.Pavarde AS "Baltais",
    ZJ.Vardas || ' ' || ZJ.Pavarde AS "Juodais",
    P.Rezultatas
FROM kisp0844.Partijos P
JOIN kisp0844.ZaidziaBaltais ZBL ON P.ID = ZBL.PartijosID
JOIN kisp0844.Zaidejai ZB ON ZBL.ZaidejoId = ZB.ZaidejoId
JOIN kisp0844.ZaidziaJuodais ZJL ON P.ID = ZJL.PartijosID
JOIN kisp0844.Zaidejai ZJ ON ZJL.ZaidejoId = ZJ.ZaidejoId
LIMIT 10;
