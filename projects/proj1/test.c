#include <stdio.h>
#include <math.h>
#include <string.h>
#include <unistd.h>
//#include <stdlib.h>
#include <ctype.h>

#define MAXWORD 100
#define BUFSIZE 100
#define MAXLINES 5000
#define MAXLINE 1000
#define MAXLEN 1000
#define ALLOCSIZE 10000

static char allocbuf[ALLOCSIZE];
static char *allocp = allocbuf;
char *lineptr[MAXLINES];
char buf[BUFSIZE];
int bufp = 0;

struct list {
    int item;
    struct list *next;
};

struct key {
    char *word;
    int count;
} keytab[] = {
        "auto", 0,
        "break", 0,
        "case", 0,
        "char", 0,
        "const", 0,
        "continue", 0,
        "default", 0,
        "unsigned", 0,
        "void", 0,
        "volatile", 0,
        "while", 0
};
#define NKEYS (sizeof keytab / sizeof(struct key))

//int getch();

void ungetch(int c);

unsigned int floorMod(unsigned int x, unsigned int y);

unsigned int stringHash(void *s);

int getword(char *, int);

struct key *binsearch(char *, struct key *, int);

int readlines(char *lineptr[], int nlines);

void writelines(char *lineptr[], int nlines);

void qsort(char *lineptr[], int left, int right);

int getlineself(char s[], int lim);

char *alloc(int n);

void afree(char *p);

void swap(char *v[], int i, int j);

//void test1();

//void test2();

int test3();

int main(int argc, char **argv) {
//    test1();
//    test2();
    test3();
    return 0;
}

//int getch() {
//    return (bufp > 0) ? buf[--bufp] : getchar();
//}

void ungetch(int c) {
    if (bufp >= BUFSIZE) {
        printf("ungetch: too many characters\n");
    } else {
        buf[bufp++] = c;
    }
}

//void test1() {
//    char word[MAXWORD];
//    struct key *p;
//    while (getword(word, MAXWORD) != EOF) {
//        if (isalpha(word[0])) {
//            if ((p = binsearch(word, keytab, NKEYS)) != NULL) {
//                p->count++;
//            }
//        }
//    }
//    for (p = keytab; p < keytab + NKEYS; p++) {
//        if (p->count > 0) {
//        printf("%4d %s\n", p->count, p->word);
//        }
//    }
//}

//void test2() {
//    char word[MAXWORD];
//    int result = getword(word, MAXWORD);
//    printf("%d", result);
//}

int test3() {
    int nlines;

    if ((nlines = readlines(lineptr, MAXLINES)) >= 0) {
        qsort(lineptr, 0, nlines - 1);
        writelines(lineptr, nlines);
        return 0;
    } else {
        printf("error: input too big to sort\n");
        return 1;
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

//int getword(char *word, int lim) {
//    int c, getch(void);
//    void ungetch(int);
//    char *w = word;
//
//    while (isspace(c = getch()));
//    if (c != EOF) {
//        *w++ = c;
//    }
//    if (!isalpha(c)) {
//        *w = '\0';
//        return c;
//    }
//
//    for (; --lim > 0; w++) {
//        if (!isalnum(*w = getch())) {
//            ungetch(*w);
//            break;
//        }
//    }
//    *w = '\0';
//    return word[0];
//}

struct key *binsearch(char *word, struct key *tab, int n) {
    int cond;
    struct key *low = &tab[0];
    struct key *high = &tab[n];
    struct key *mid;

    while (low < high) {
        mid = low + (high - low) / 2;
        if ((cond = strcmp(word, mid->word)) < 0)
            high = mid;
        else if (cond > 0)
            low = mid + 1;
        else
            return mid;
    }
    return NULL;
}

int getlineself(char s[], int lim) {
    int c, i;

    for (i = 0; i < lim - 1 && (c = getchar()) != EOF && c != '\n'; ++i) {
        s[i] = c;
    }
    if (c == '\n') {
        s[i] = c;
        i++;
    }
    s[i] = '\0';
    return i;
}

int readlines(char *lineptr[], int maxlines) {
    int len, nlines;
    char *p, line[MAXLINE];

    nlines = 0;
    while ((len = getlineself(line, MAXLEN)) > 0) {
        if (nlines >= maxlines || (p = alloc(len)) == NULL) {
            return -1;
        } else {
            line[len - 1] = '\0';
            strcpy(p, line);
            lineptr[nlines++] = p;
        }
    }
    return nlines;
}

void writelines(char *lineptr[], int nlines) {
    int i;

    for (i = 0; i < nlines; i++) {
        printf("%s\n", lineptr[i]);
    }
}

void qsort(char *v[], int left, int right) {
    int i, last;
    void swap(char *v[], int i, int j);

    if (left >= right) {
        return;
    }

    swap(v, left, (left + right) / 2);
    last = left;
    for (i = left + 1; i <= right; i++) {
        if (strcmp(v[i], v[left]) < 0) {
            swap(v, ++last, i);
        }
    }
    swap(v, left, last);
    qsort(v, left, last - 1);
    qsort(v, last + 1, right);
}

void swap(char *v[], int i, int j) {
    char *temp;

    temp = v[i];
    v[i] = v[j];
    v[j] = temp;
}

char *alloc(int n) {
    if (allocbuf + ALLOCSIZE - allocp >= n) {
        allocp += n;
        return allocp - n;
    } else {
        return 0;
    }
}

void afree(char *p) {
    if (p >= allocbuf && p < allocbuf + ALLOCSIZE) {
        allocp = p;
    }
}