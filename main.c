.LOG

1-a mini užduotėlė: programavimo kalba C parašyti:
funkcijas suma ir dalmuo su liekana.

Dalmenį ir liekaną grąžinkite per funkcijos parametrus,
o klaidos kodą per funkcijos vardą.

Jeigu išeina, abiem funkcijoms komentaruose nurodykite
// precondition:
// postcondition:

Šį Questions.txt failą patalpinkite
U:\www\ADS2025\Questions.txt
ir jame pateikite savo mini užduotėles sprendimą.

Taip pat, šiame faile galite pateikti individualius klausimus.

----------------------------------------------------------------------------

#include <stdio.h>

int suma(int a, int b, int *sumos_rezultatas) {
    if (sumos_rezultatas == NULL) {
        return -1;
    }
    *sumos_rezultatas = a + b;
    return 0;
}

int dalmuo(int a, int b, int *dalmens_rezultatas, int *liekanos_rezultatas) {
    if (b == 0 || dalmens_rezultatas == NULL || liekanos_rezultatas == NULL) {
        return -1;
    }
    *dalmens_rezultatas = a / b;
    *liekanos_rezultatas = a % b;
    return 0;
}

int main() {
    int a = 10, b = 3;
    int suma_rezultatas, dalmuo_rezultatas, liekana;

    if (suma(a, b, &suma_rezultatas) == 0) {
        printf("Suma: %d\n", suma_rezultatas);
    } else {
        printf("Klaida skaičiuojant sumą.\n");
    }

    if (dalmuo(a, b, &dalmuo_rezultatas, &liekana) == 0) {
        printf("Dalmuo: %d, Liekana: %d\n", dalmuo_rezultatas, liekana);
    } else {
        printf("Klaida skaičiuojant dalybą.\n");
    }

    return 0;
}
