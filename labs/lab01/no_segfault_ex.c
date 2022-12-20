#include <stdio.h>
int main() {
    int a[5] = {1, 2, 3, 4, 5};
    unsigned total = 0;
    printf("array len: %ld\n", sizeof(a) / sizeof(int));
    for (int j = 0; j < sizeof(a) / sizeof(int); j++) {
        total += a[j];
    }
    printf("sum of array is %d\n", total);
}