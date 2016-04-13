#include <stdlib.h>
#include <stdio.h>

#include "flow.h"

/*
    1. Dane o macierzy przechowywane są w zmiennych globalnych z przedrostkiem mm_flow_
    2. Jedyna modyfikacja macierzy jaka nalezy wykonac przed wywolaniem start(),
       to stworzenie transponowanej kopii. Ma to na celu umozliwienie obliczania "wierszami"
    3. Program nie obsługuje przypadku dla wysokosc <= 1.
       Zalozylem, ze glownym celem zadania jest uzycie SSE i nie ma sensu rozpatrywanie tego
       przypadku. Mam nadzieje ze to sluszne zalozenie.
    4. Roznice miedzy zanieczyszczeniem, a komorka zapisywane sa w tymczasowej tablicy,
       po czym wszystkie wartosci sa dodawane do wlasciwej macierzy (z uzyciem SSE)
*/

float *transpose(float *raw, int width, int height) {
    // additional 4 floats to avoid reading after array
    float *res = malloc((width * height + 4) * sizeof(float));
    int i, j;
    for (i = 0; i < height; i++) {
        for (j = 0; j < width; j++) {
            res[j * height + i] = raw[i * width + j];
        }
    }
    return res;
}

void print(float *m, int width, int height) {
    int i;
    int j;
    // m is the transpose of an input, so we need the transpose of a matrix
    int tmp = width;
    width = height;
    height = tmp;

    for (j = 0; j < width; j++) {
        for (i = 0; i < height; i++) {
            printf("%f ", m[i * width + j]);
        }
        puts("");
    }

    for (i = 0; i < 80; i++) {
        printf("-");
    }
    puts("");
}

int main(int argc, char **argv) {
    if (argc < 2) {
        printf("Usage: %s input_file\n", argv[0]);
        return 0;
    }

    FILE *input = fopen(argv[1], "r");
    if (!input) {
        puts("Unable to open input file");
        return 0;
    }

    int width;
    int height;
    float weight;
    fscanf(input, "%d %d %f", &width, &height, &weight);

    float mtx_in[width * height];
    int i, j;
    for (i = 0; i < height; i++) {
        for (j = 0; j < width; j++) {
            fscanf(input, "%f", &(mtx_in[i * width + j]));
        }
    }

    float *mtx = transpose(mtx_in, width, height);

    // switched height with width
    start(height, width, mtx, weight);
    puts("input:");
    print(mtx, width, height);

    int count;
    float step_tab[height];
    fscanf(input, "%d", &count);
    for (i = 0; i < count; i++) {
        for (j = 0; j < height; j++) {
            fscanf(input, "%f", step_tab + j);
        }

        step(step_tab);
        printf("step %d\n", i + 1);
        print(mtx, width, height);
    }
}