#include <stdio.h>
#include <stdlib.h>
int fib(int n);
int main(int argc, char** argv) {
    printf("%s, %d\n", argv[1], fib(atoi(argv[1])));
}

int fib(int n) {
    if (n == 0 || n == 1) {
        return n;
    }
    return fib(n - 1) + fib(n - 2);
}