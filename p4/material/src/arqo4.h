#ifndef _ARQO_P4_H_
#define _ARQO_P4_H_

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#if __x86_64__
	typedef float tipo;
#else
	typedef float tipo;
#endif

#define N 1000ull
#define M 1000000ull

float ** generateMatrix(int);
float ** generateEmptyMatrix(int);
void freeMatrix(float **);
float * generateVector(int);
float * generateVectorOne(int);
float * generateEmptyVector(int);
int * generateEmptyIntVector(int);
void freeVector(void *);

#endif /* _ARQO_P4_H_ */
