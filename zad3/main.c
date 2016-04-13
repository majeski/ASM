#include <stdlib.h>
#include <stdio.h>

#include "flow.h"

/*
    1. Dane o macierzy przechowywane są w zmiennych globalnych z przedrostkiem mm_flow_
    2. Przed przetwarzaniem macierz jest transponowana, a floaty zamieniane na fixed
    3. Roznice miedzy zanieczyszczeniem, a komorka zapisywane sa w tymczasowej tablicy,
       po czym wszystkie wartosci sa mnozone przez wage oraz dodawane do wlasciwej macierzy
    4. Podobnie jak w zad2 nie obsluguje przypadku z tablica jednowierszowa
*/

fixed to_fixed(float f) {
    return (int)(f * (float)(1 << 8));
}

float from_fixed(fixed i) {
    return (float)i / (float)(1 << 8);
}

fixed *transpose(fixed *raw, int width, int height) {
    fixed *res = malloc((width * height) * sizeof(fixed));
    int i, j;
    for (i = 0; i < height; i++) {
        for (j = 0; j < width; j++) {
            res[j * height + i] = raw[i * width + j];
        }
    }
    return res;
}

void print(fixed *m, int width, int height) {
    int i;
    int j;
    // m is the transpose of an input, so we need the transpose of a matrix
    int tmp = width;
    width = height;
    height = tmp;

    for (j = 0; j < width; j++) {
        for (i = 0; i < height; i++) {
            printf("%f ", from_fixed(m[i * width + j]));
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

    fixed mtx_in[width * height];
    int i, j;
    for (i = 0; i < height; i++) {
        for (j = 0; j < width; j++) {
            float x; 
            fscanf(input, "%f", &x);
            mtx_in[i * width + j] = to_fixed(x);
        }
    }

    fixed *mtx = transpose(mtx_in, width, height);

    // switched height with width
    start(height, width, mtx, to_fixed(weight));

    puts("input:");
    print(mtx, width, height);

    int count;
    fixed step_tab[height];
    fscanf(input, "%d", &count);
    for (i = 0; i < count; i++) {
        for (j = 0; j < height; j++) {
            float x;
            fscanf(input, "%f", &x);
            step_tab[j] = to_fixed(x);
        }

        step(step_tab);
        printf("step %d\n", i + 1);
        print(mtx, width, height);
    }

    fclose(input);
}
