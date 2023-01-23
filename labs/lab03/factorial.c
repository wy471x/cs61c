#include <stdio.h>
#include <stdlib.h>

int factorial(int n);

int main(int argc, char **argv) {
    factorial(atoi(argv[1]));
}

int factorial(int n) {
    if (n == 1) {
        return n;
    }
    return n * factorial(n - 1);
}