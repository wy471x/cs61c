#include <stdio.h>
#include <math.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>

struct list {
    int item;
    struct list *next;
};

unsigned int floorMod(unsigned int x, unsigned int y);

unsigned int stringHash(void *s);

int main(int argc, char **argv) {
//    char strings[100] = "\0";
//    while (fgets(strings, 100, stdin)) {
//        printf("%s\n", strings);
//        printf("%d\n", stringHash(strings));
//        printf("%d\n", floorMod(stringHash(strings), 2255));
//    }
//strlen(NULL);

//    if (access(argv[1], F_OK) != 0) {
//        fprintf(stderr, "specified file is not exist.");
//        exit(1);
//    }
//
//    FILE *fp = fopen(argv[1], "r");
//    char word[60];
//    while (fscanf(fp, "%s", word) != EOF) {
//        printf("%s\n", word);
//    }
//    fclose(fp);
//    char str[80] = "This is - www.tutorialspoint.com - website";
//    const char s[2] = "-";
//    char *token;
//
//    /* get the first token */
//    token = strtok(str, s);
//
//    /* walk through other tokens */
//    while( token != NULL ) {
//        printf( " %s\n", token );
//
//        token = strtok(NULL, s);
//    }
//
//    return(0);
//    printf("%d\n", stringHash("this"));
//    printf("%s\n", strings);
//    printf("%ld\n", strlen(strings));
//    char strings[60] = "this is a misspelled word.";
//    char *ptr = strings;
//    char newString[60] = "";
//    char *newPtr = newString;
//    while (*ptr != '\0') {
//        strcpy(newPtr, ptr);
//        ptr++;
//        newPtr++;
//    }
//    printf("string: %s, new string: %s\n", strings, newString);
//    printf("%ld\n", strlen(""));
    char **dPtr = malloc(sizeof(char *) * 10);
    char str[10][2] = {"01", "23","45","67","89", "ab","cd","ef","gh","ij"};
    for (int i = 0; i < 10; i++) {
        dPtr[i] = str[i];
    }
    for (int i = 0; i < 10; i++) {
        printf("%s\n", dPtr[i]);
    }
}

void test1() {
    struct list *lp, *prevlp;
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