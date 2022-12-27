#include <stdio.h>
#include <math.h>
#include <string.h>

unsigned int floorMod(unsigned int x, unsigned int y);

unsigned int stringHash(void *s);

int main() {
    char strings[100];
    while (fgets(strings, 100, stdin)) {
        printf("%s\n", strings);
        printf("%d\n", stringHash(strings));
        printf("%d\n", floorMod(stringHash(strings), 2255));
    }
}

unsigned int stringHash(void *s) {
    char *string = (char *) s;
    // -- TODO --
    int hashCode = 0, len = strlen(string), i = 0;
    while (*string != '\0') {
        hashCode += pow(27, (len - 1 - i));
        i++;
        string++;
    }
    printf("%d\n", hashCode);
    return hashCode % 2255;
}

unsigned int floorMod(unsigned int x, unsigned int y) {
    return x - (x / y) * y;
}