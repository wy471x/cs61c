#include <stdio.h>
#include <string.h>
#include <malloc.h>

int main(int argc, char** argv) {
    char input[] ="first second third forth";
    char delimiter[] = " ";
    char *firstWord, *secondWord, *remainder, *context;

    int inputLength = strlen(input);
    char *inputCopy = (char*) calloc(inputLength + 1, sizeof(char));
    strncpy(inputCopy, input, inputLength);

    firstWord = strtok_r (inputCopy, delimiter, &context);
    secondWord = strtok_r (NULL, delimiter, &context);
    remainder = context;

    printf("%s\n", firstWord);
    printf("%s\n", secondWord);
    printf("%s\n", remainder);

    getchar();
    free(inputCopy);
    return 0;
}