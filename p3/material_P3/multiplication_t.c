#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo3.h"

void multiply_t(tipo **a, tipo **bt, tipo **c, int n);
void transpose(tipo **b, int n);
void freeMatrixes(tipo **a, tipo **b, tipo **c);

int main(int argc, char *argv[])
{
	int n;
	tipo **a = NULL, **b = NULL, **c = NULL;
	struct timeval fin, ini;

	printf("Word size: %ld bits\n", 8 * sizeof(tipo));

	if (argc != 2)
	{
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n = atoi(argv[1]);
	if (!(a = generateMatrix(n)) || !(b = generateMatrix(n)) || !(c=generateEmptyMatrix(n)))
	{
		freeMatrixes(a, b, c);
		return -1;
	}

	gettimeofday(&ini, NULL);
	/* Main computation */
	transpose(b, n);
	multiply_t(a, b, c, n);
	/* End of computation */
	gettimeofday(&fin, NULL);

	printf("Execution time: %f\n", ((fin.tv_sec * 1000000 + fin.tv_usec) - (ini.tv_sec * 1000000 + ini.tv_usec)) * 1.0 / 1000000.0);

	freeMatrixes(a, b, c);
	return 0;
}

void multiply_t(tipo **a, tipo **bt, tipo **c, int n)
{
	int i, j, k;

	for (i = 0; i < n; i++)
	{
		for (j = 0; j < n; j++)
		{
			for(c[i][j] = 0, k = 0; k < n; k++)
			{
				c[i][j] += a[i][k] * bt[j][k];
			}
		}
	}
}

void transpose(tipo **b, int n)
{
	tipo x;
	int i,j;
	for(i = 0; i < n; i++)
	{
		for(j = 0; j < n; j++)
		{
			x = b[j][i];
			b[j][i] = b[i][j];
			b[i][j] = x;
		}
	}
}

void freeMatrixes(tipo **a, tipo **b, tipo **c)
{
	if(a) freeMatrix(a);
	if(b) freeMatrix(b);
	if(c) freeMatrix(c);
}