#include "bit_ops.h"
#include <stdio.h>
#include <stdlib.h>

void test1(int x, int n);

int main(int argc, char **argv) {
    test1(atoi(argv[1]), atoi(argv[2]));
    return 0;
}

void test1(int x, int n) {
    printf("x = %d n = %d  result = %d\n", x, n, get_bit(x, n));
}