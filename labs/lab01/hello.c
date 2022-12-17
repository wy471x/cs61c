#include <stdio.h>
// declare function define.
int sum(int a, int b);

int main(int argc, char *argv[]) {
    int i;
    int count = 0;
    int *p = &count;

    printf("%d\n", argc);
    printf("hello, world!\n");
    for (i = 1; i < argc; i++) {
        (*p)++; // Do you understand this line of code and all the other permutations of the operators? ;)
        printf("%s ", argv[i]);
    }
    printf("%d\n", sum(1, 2));
//    printf("%d", 1 / 0);
    printf("\n");

    printf("Thanks for waddling through this program. Have a nice day.");
    return 0;
}

int sum(int a, int b) {
    printf("%d, %d", a, b);
    return a + b;
}