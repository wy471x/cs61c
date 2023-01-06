#include "bit_ops.h"
#include <stdio.h>
#include <stdlib.h>

void test1(int x, int n);

void test2(int x, int n, int v);

void test3(int x, int n);

int main(int argc, char **argv) {
    test1(atoi(argv[1]), atoi(argv[2]));
//    test2(atoi(argv[1]), atoi(argv[2]), atoi(argv[3]));
//    test3(atoi(argv[1]), atoi(argv[2]));
    return 0;
}

void test1(int x, int n) {
    printf("x = %d n = %d  result = %d\n", x, n, get_bit(x, n));
}

void test2(int x, int n, int v) {
    printf("x = %d ", x);
    set_bit(&x, n, v);
    printf("n = %d v = %d result = %d\n", n, v, x);
}

void test3(int x, int n) {
    printf("x = %d ", x);
    flip_bit(&x, n);
    printf("n = %d result = %d\n", n, x);
}