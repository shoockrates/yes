/*
  failas: chess_app.pgc
  kompiliavimas (pavyzdys):
    ecpg chess_app.pgc
    gcc -o chess_app chess_app.c -lecpg

  Pastaba: pakeisk CONNECT target/user/password pagal savo aplinką.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void clear_stdin(void) {
    int c;
    while ((c = getchar()) != '\n' && c != EOF) {}
}

static int read_int(const char *prompt, int *out) {
    printf("%s", prompt);
    if (scanf("%d", out) != 1) {
        clear_stdin();
        return 0;
    }
    clear_stdin();
    return 1;
}

static int read_double(const char *prompt, double *out) {
    printf("%s", prompt);
    if (scanf("%lf", out) != 1) {
        clear_stdin();
        return 0;
    }
    clear_stdin();
    return 1;
}

static int read_str_line(const char *prompt, char *buf, size_t cap) {
    printf("%s", prompt);
    if (!fgets(buf, (int)cap, stdin)) return 0;
    size_t n = strlen(buf);
    if (n && buf[n-1] == '\n') buf[n-1] = '\0';
    return 1;
}

/* --- Prototipai --- */
void PerziuretiZaidejuStatistika(void);
void PerziuretiVarzybuPartijas(void);
void RegistruotiNaujaZaideja(void);
void AtnaujintiZaidejoReitinga(void);
void IstrintiZaidejaSuTransakcija(void);
void RegistruotiPartija(void);
void Iseiti(void);

int main(void) {
    int pasirinkimas = -1;

    /* Prisijungimas prie DB */
    EXEC SQL CONNECT TO studentu@pgsql3.mif USER "maka1208" USING "...";
    if (sqlca.sqlcode != 0) {
        printf("Prisijungimo klaida! SQLCODE=%ld\n", sqlca.sqlcode);
        return 1;
    }

    /* Kad nereikėtų prefikso kisp0844. kiekvienam objektui */
    EXEC SQL SET search_path TO kisp0844;

    printf("Prisijungta prie DB sėkmingai.\n");

    while (pasirinkimas != 0) {
        printf("\n===== ŠACHMATŲ DB VALDYMO PROGRAMA (kisp0844) =====\n");
        printf("1. Peržiūrėti žaidėjų statistiką (VIEW)\n");
        printf("2. Peržiūrėti varžybų partijas (JOIN kelių lentelių)\n");
        printf("3. Užregistruoti naują žaidėją (INSERT)\n");
        printf("4. Atnaujinti žaidėjo reitingą (UPDATE)\n");
        printf("5. Ištrinti žaidėją + jo atsiliepimus (TRANSAKCIJA)\n");
        printf("6. Užregistruoti naują partiją (INSERT į Partijos; trigeriai veiks)\n");
        printf("0. Baigti\n");

        if (!read_int("Pasirinkite veiksmą: ", &pasirinkimas)) {
            printf("Netinkamas pasirinkimas!\n");
            pasirinkimas = -1;
            continue;
        }

        switch (pasirinkimas) {
            case 1: PerziuretiZaidejuStatistika(); break;
            case 2: PerziuretiVarzybuPartijas(); break;
            case 3: RegistruotiNaujaZaideja(); break;
            case 4: AtnaujintiZaidejoReitinga(); break;
            case 5: IstrintiZaidejaSuTransakcija(); break;
            case 6: RegistruotiPartija(); break;
            case 0: Iseiti(); break;
            default: printf("Netinkamas pasirinkimas, bandykite dar kartą.\n");
        }
    }

    EXEC SQL DISCONNECT;
    return 0;
}

/* ============================================================
   1) DUOMENŲ PAIEŠKA: VIEW kisp0844.ŽaidėjųStatistika
   ============================================================ */
void PerziuretiZaidejuStatistika(void) {
    EXEC SQL BEGIN DECLARE SECTION;
        int id;
        char vardas[51];
        char pavarde[51];
        int pergales;
        int pralaimejimai;
        int lygiosios;
    EXEC SQL END DECLARE SECTION;

    EXEC SQL WHENEVER SQLERROR GOTO error;
    EXEC SQL WHENEVER NOT FOUND GOTO end;

    EXEC SQL DECLARE cur CURSOR FOR
        SELECT "ŽaidėjoId", "Vardas", "Pavardė", "Pergalės", "Pralaimėjimai", "Lygiosios"
        FROM "ŽaidėjųStatistika"
        ORDER BY "Pavardė", "Vardas";

    EXEC SQL OPEN cur;

    printf("\n==== Žaidėjų statistika ====\n");
    printf("%-5s %-20s %-20s %-9s %-12s %-9s\n", "ID", "Vardas", "Pavardė", "Pergalės", "Pralaimėjimai", "Lygiosios");

    while (1) {
        EXEC SQL FETCH cur INTO :id, :vardas, :pavarde, :pergales, :pralaimejimai, :lygiosios;
        if (sqlca.sqlcode == 100) break;

        printf("%-5d %-20s %-20s %-9d %-12d %-9d\n",
               id, vardas, pavarde, pergales, pralaimejimai, lygiosios);
    }

end:
    EXEC SQL CLOSE cur;
    return;

error:
    printf("SQL klaida: %s (SQLCODE=%ld)\n", sqlca.sqlerrm.sqlerrmc, sqlca.sqlcode);
    EXEC SQL CLOSE cur;
}

/* ============================================================
   2) DUOMENŲ PAIEŠKA su 2+ susijusiom lentelėm: Varžybos + Partijos + Žaidėjai
   ============================================================ */
void PerziuretiVarzybuPartijas(void) {
    EXEC SQL BEGIN DECLARE SECTION;
        int varzybu_id;
        char vieta[101];
        char data[11];      /* YYYY-MM-DD */

        int partijos_id;
        int lenta;
        int turas;
        char rezultatas[11];

        char baltu_v[51], baltu_p[51];
        char juodu_v[51], juodu_p[51];

        int input_varzybu_id;
        int cnt;
    EXEC SQL END DECLARE SECTION;

    EXEC SQL WHENEVER SQLERROR GOTO error;

    /* Reikalavimas: prieš prašant ID parodyti esamus ID + prasminius laukus */
    printf("\n==== Galimos varžybos (ID / vieta / data / kategorija) ====\n");

    EXEC SQL DECLARE curV CURSOR FOR
        SELECT "VaržybųId", "Vieta", to_char("Data", 'YYYY-MM-DD')
        FROM "Varžybos"
        ORDER BY "Data", "VaržybųId";

    EXEC SQL OPEN curV;

    printf("%-6s %-20s %-12s\n", "ID", "Vieta", "Data");
    while (1) {
        EXEC SQL FETCH curV INTO :varzybu_id, :vieta, :data;
        if (sqlca.sqlcode == 100) break;
        printf("%-6d %-20s %-12s\n", varzybu_id, vieta, data);
    }
    EXEC SQL CLOSE curV;

    if (!read_int("\nĮveskite VaržybųId, kurių partijas rodyti: ", &input_varzybu_id)) {
        printf("Blogas įvedimas.\n");
        return;
    }

    /* patikrinam ar egzistuoja */
    EXEC SQL SELECT COUNT(*) INTO :cnt
             FROM "Varžybos"
             WHERE "VaržybųId" = :input_varzybu_id;

    if (cnt == 0) {
        printf("Varžybos su ID %d nerastos.\n", input_varzybu_id);
        return;
    }

    EXEC SQL WHENEVER NOT FOUND GOTO end;

    EXEC SQL DECLARE curP CURSOR FOR
        SELECT
            p."ID",
            p."LentosNr",
            p."Turas",
            p."Rezultatas",
            zb."Vardas", zb."Pavardė",
            zj."Vardas", zj."Pavardė"
        FROM "Partijos" p
        JOIN "Žaidėjai" zb ON p."BaltųŽaidėjuId" = zb."ŽaidėjoId"
        JOIN "Žaidėjai" zj ON p."JuodųŽaidėjuId" = zj."ŽaidėjoId"
        WHERE p."VaržybųId" = :input_varzybu_id
        ORDER BY p."Turas", p."LentosNr", p."ID";

    EXEC SQL OPEN curP;

    printf("\n==== Varžybų %d partijos ====\n", input_varzybu_id);
    printf("%-6s %-6s %-6s %-10s %-20s %-20s\n", "PID", "Lenta", "Turas", "Rezult.", "Balti", "Juodi");

    while (1) {
        EXEC SQL FETCH curP INTO :partijos_id, :lenta, :turas, :rezultatas,
                                 :baltu_v, :baltu_p, :juodu_v, :juodu_p;
        if (sqlca.sqlcode == 100) break;

        char balti[120], juodi[120];
        snprintf(balti, sizeof(balti), "%s %s", baltu_v, baltu_p);
        snprintf(juodi, sizeof(juodi), "%s %s", juodu_v, juodu_p);

        printf("%-6d %-6d %-6d %-10s %-20s %-20s\n",
               partijos_id, lenta, turas, rezultatas, balti, juodi);
    }

end:
    EXEC SQL CLOSE curP;
    return;

error:
    printf("SQL klaida: %s (SQLCODE=%ld)\n", sqlca.sqlerrm.sqlerrmc, sqlca.sqlcode);
    EXEC SQL WHENEVER SQLERROR CONTINUE;
    EXEC SQL CLOSE curV;
    EXEC SQL CLOSE curP;
}

/* ============================================================
   3) DUOMENŲ ĮVEDIMAS: „Užregistruoti naują žaidėją“
   ============================================================ */
void RegistruotiNaujaZaideja(void) {
    EXEC SQL BEGIN DECLARE SECTION;
        char vardas[51];
        char pavarde[51];
        char gimimo_data[11]; /* YYYY-MM-DD */
        int reitingas;
        char gatve[51];
        char butas[11];
        char namas[11];
        int naujas_id;
    EXEC SQL END DECLARE SECTION;

    EXEC SQL WHENEVER SQLERROR GOTO error;

    printf("\n=== Užregistruoti naują žaidėją ===\n");

    if (!read_str_line("Vardas: ", vardas, sizeof(vardas))) return;
    if (!read_str_line("Pavardė: ", pavarde, sizeof(pavarde))) return;
    if (!read_str_line("Gimimo data (YYYY-MM-DD): ", gimimo_data, sizeof(gimimo_data))) return;

    if (!read_int("Reitingas (>=0): ", &reitingas)) {
        printf("Blogas reitingas.\n");
        return;
    }

    if (!read_str_line("Gatvė (gali būti tuščia): ", gatve, sizeof(gatve))) return;
    if (!read_str_line("Butas (gali būti tuščia): ", butas, sizeof(butas))) return;
    if (!read_str_line("Namas (gali būti tuščia): ", namas, sizeof(namas))) return;

    /* Paprasta „null“ logika: jei tuščia - įrašom NULL */
    EXEC SQL INSERT INTO "Žaidėjai"
        ("Pavardė","GimimoData","Vardas","Reitingas","Gatvė","Butas","Namas")
    VALUES
        (:pavarde, :gimimo_data::date, :vardas, :reitingas,
         NULLIF(:gatve, ''), NULLIF(:butas, ''), NULLIF(:namas, ''));

    EXEC SQL SELECT currval(pg_get_serial_sequence('kisp0844."Žaidėjai"', 'ŽaidėjoId'))
             INTO :naujas_id;

    EXEC SQL COMMIT;
    printf("Žaidėjas įregistruotas. Naujas ŽaidėjoId = %d\n", naujas_id);
    return;

error:
    printf("SQL klaida: %s (SQLCODE=%ld)\n", sqlca.sqlerrm.sqlerrmc, sqlca.sqlcode);
    EXEC SQL ROLLBACK;
}

/* ============================================================
   4) DUOMENŲ ATNAUJINIMAS: „Atnaujinti žaidėjo reitingą“
   ============================================================ */
void AtnaujintiZaidejoReitinga(void) {
    EXEC SQL BEGIN DECLARE SECTION;
        int id;
        int naujas_reitingas;
        int cnt;
        char vardas[51];
        char pavarde[51];
        int senas_reitingas;
    EXEC SQL END DECLARE SECTION;

    EXEC SQL WHENEVER SQLERROR GOTO error;

    printf("\n=== Atnaujinti žaidėjo reitingą ===\n");

    if (!read_int("Įveskite ŽaidėjoId: ", &id)) {
        printf("Blogas įvedimas.\n");
        return;
    }

    EXEC SQL SELECT COUNT(*) INTO :cnt
             FROM "Žaidėjai"
             WHERE "ŽaidėjoId" = :id;

    if (cnt == 0) {
        printf("Žaidėjas su ID %d nerastas.\n", id);
        return;
    }

    EXEC SQL SELECT "Vardas","Pavardė","Reitingas"
             INTO :vardas, :pavarde, :senas_reitingas
             FROM "Žaidėjai"
             WHERE "ŽaidėjoId" = :id;

    printf("Žaidėjas: %s %s | Dabartinis reitingas: %d\n", vardas, pavarde, senas_reitingas);

    if (!read_int("Įveskite naują reitingą (>=0): ", &naujas_reitingas)) {
        printf("Blogas įvedimas.\n");
        return;
    }
    if (naujas_reitingas < 0) {
        printf("Reitingas negali būti neigiamas.\n");
        return;
    }

    EXEC SQL UPDATE "Žaidėjai"
             SET "Reitingas" = :naujas_reitingas
             WHERE "ŽaidėjoId" = :id;

    EXEC SQL COMMIT;
    printf("Reitingas atnaujintas: %d -> %d\n", senas_reitingas, naujas_reitingas);
    return;

error:
    printf("SQL klaida: %s (SQLCODE=%ld)\n", sqlca.sqlerrm.sqlerrmc, sqlca.sqlcode);
    EXEC SQL ROLLBACK;
}

/* ============================================================
   5) TRYNIMAS + TRANSAKCIJA: „Ištrinti žaidėją ir jo atsiliepimus“
   (keli modifikavimo sakiniai vienoje transakcijoje)
   ============================================================ */
void IstrintiZaidejaSuTransakcija(void) {
    EXEC SQL BEGIN DECLARE SECTION;
        int id;
        int cnt;
        char vardas[51];
        char pavarde[51];
        int kiek_review;
        int kiek_partiju;
        char confirm[8];
    EXEC SQL END DECLARE SECTION;

    EXEC SQL WHENEVER SQLERROR GOTO error;

    printf("\n=== Ištrinti žaidėją (su transakcija) ===\n");

    /* Reikalavimas: prieš prašant ID parodyti esamus ID su prasminiais laukais */
    printf("\nEsami žaidėjai:\n");
    EXEC SQL DECLARE cur CURSOR FOR
        SELECT "ŽaidėjoId", "Vardas", "Pavardė"
        FROM "Žaidėjai"
        ORDER BY "Pavardė","Vardas";

    EXEC SQL OPEN cur;
    printf("%-6s %-20s %-20s\n", "ID", "Vardas", "Pavardė");
    while (1) {
        EXEC SQL FETCH cur INTO :id, :vardas, :pavarde;
        if (sqlca.sqlcode == 100) break;
        printf("%-6d %-20s %-20s\n", id, vardas, pavarde);
    }
    EXEC SQL CLOSE cur;

    if (!read_int("\nĮveskite ŽaidėjoId, kurį šalinti: ", &id)) {
        printf("Blogas įvedimas.\n");
        return;
    }

    EXEC SQL SELECT COUNT(*) INTO :cnt
             FROM "Žaidėjai"
             WHERE "ŽaidėjoId" = :id;

    if (cnt == 0) {
        printf("Žaidėjas su ID %d nerastas.\n", id);
        return;
    }

    EXEC SQL SELECT "Vardas","Pavardė" INTO :vardas,:pavarde
             FROM "Žaidėjai"
             WHERE "ŽaidėjoId" = :id;

    EXEC SQL SELECT COUNT(*) INTO :kiek_review
             FROM "ParašytasAtsiliepimaS"
             WHERE "ŽaidėjoId" = :id;

    EXEC SQL SELECT COUNT(*) INTO :kiek_partiju
             FROM "Partijos"
             WHERE "JuodųŽaidėjuId" = :id OR "BaltųŽaidėjuId" = :id;

    printf("Šalinsite: %s %s (ID=%d). Review įrašų: %d. Partijų: %d.\n",
           vardas, pavarde, id, kiek_review, kiek_partiju);

    if (!read_str_line("Patvirtinti? (TAIP/NE): ", confirm, sizeof(confirm))) return;
    if (strcmp(confirm, "TAIP") != 0) {
        printf("Atšaukta.\n");
        return;
    }

    /* Realus transakcijos pavyzdys: 2 modifikavimo sakiniai */
    EXEC SQL BEGIN;

    EXEC SQL DELETE FROM "ParašytasAtsiliepimaS"
             WHERE "ŽaidėjoId" = :id;

    EXEC SQL DELETE FROM "Žaidėjai"
             WHERE "ŽaidėjoId" = :id;

    EXEC SQL COMMIT;

    printf("Žaidėjas ir jo atsiliepimai ištrinti.\n");
    return;

error:
    printf("SQL klaida: %s (SQLCODE=%ld)\n", sqlca.sqlerrm.sqlerrmc, sqlca.sqlcode);
    EXEC SQL ROLLBACK;
}

/* ============================================================
   6) DUOMENŲ ĮVEDIMAS (domeno veiksmas): „Užregistruoti partiją“
   - čia suveiks tavo trigeriai (maks dalyviai, žaidėjų egzistavimas)
   ============================================================ */
void RegistruotiPartija(void) {
    EXEC SQL BEGIN DECLARE SECTION;
        int varzybu_id;
        int juodu_id;
        int baltu_id;
        int lenta;
        int turas;
        char rezultatas[11];
        int cnt;
        int naujas_pid;
    EXEC SQL END DECLARE SECTION;

    EXEC SQL WHENEVER SQLERROR GOTO error;

    printf("\n=== Užregistruoti naują partiją ===\n");

    if (!read_int("VaržybųId: ", &varzybu_id)) return;

    EXEC SQL SELECT COUNT(*) INTO :cnt
             FROM "Varžybos"
             WHERE "VaržybųId" = :varzybu_id;
    if (cnt == 0) {
        printf("Varžybos su tokiu ID neegzistuoja.\n");
        return;
    }

    if (!read_int("JuodųŽaidėjuId: ", &juodu_id)) return;
    if (!read_int("BaltųŽaidėjuId: ", &baltu_id)) return;
    if (juodu_id == baltu_id) {
        printf("Klaida: žaidėjai turi skirtis.\n");
        return;
    }
    if (!read_int("LentosNr: ", &lenta)) return;
    if (!read_int("Turas: ", &turas)) return;

    printf("Rezultatas leidžiamas: 1-0, 0-1, 1/2-1/2, 0-0\n");
    if (!read_str_line("Rezultatas: ", rezultatas, sizeof(rezultatas))) return;

    EXEC SQL INSERT INTO "Partijos"
        ("VaržybųId","JuodųŽaidėjuId","BaltųŽaidėjuId","LentosNr","Turas","Rezultatas")
    VALUES
        (:varzybu_id, :juodu_id, :baltu_id, :lenta, :turas, :rezultatas);

    EXEC SQL SELECT currval(pg_get_serial_sequence('kisp0844."Partijos"', 'ID'))
             INTO :naujas_pid;

    EXEC SQL COMMIT;

    printf("Partija užregistruota. Naujas Partijos ID = %d\n", naujas_pid);
    return;

error:
    /* Jei suveiks tavo trigeriai, čia gausi jų klaidos tekstą */
    printf("SQL klaida: %s (SQLCODE=%ld)\n", sqlca.sqlerrm.sqlerrmc, sqlca.sqlcode);
    EXEC SQL ROLLBACK;
}

void Iseiti(void) {
    printf("Programa baigia darbą.\n");
}
