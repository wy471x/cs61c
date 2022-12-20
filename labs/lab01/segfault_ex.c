#include <stdio.h>
int main() {
    int a[20];
    for (int i = 0; i < sizeof(a) / sizeof(int); i++) {
        a[i] = i;
        printf("%d ", a[i]);
    }
    printf("\n");
}