#ifndef _PHILSPEL_H
#define _PHILSPEL_H

#include <stdbool.h>

extern struct HashTable *dictionary;

extern unsigned int stringHash(void *s);

extern int stringEquals(void *s1, void *s2);

extern void readDictionary(char *dictName);

extern void processInput();

extern bool isEnglishWord(char *word);

extern char* wordToLowercase(char* word);

extern char* allLetterToLowercaseExceptFirst(char* word);

extern unsigned int floorMod(unsigned int x, unsigned int y);

#endif
