#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

#include "arqo4.h"

/**
 * @file multiplication.c
 * @author Pablo Cuesta Sierra and Álvaro Zamanillo Sáez
 * @brief exercises 3 and 4. Practice 3. ARQO.
 * (Regular) Multiplication of two matrices of size NxN.
 * 
 */

/**
 * @brief calculates the multiplication AB=C
 * 
 * @param a matrix A
 * @param b matrix B
 * @param c matrix C, where the result is stored
 * @param n size of matrices is nxn
 */
void multiply(float **a, float **b, float **c, int n);

/**
 * @brief frees the three matrices
 * 
 * @param a matrix
 * @param b matrix
 * @param c matrix
 */
void freeMatrices(float **a, float **b, float **c);

int main(int argc, char *argv[])
{
	int n;
	float **a = NULL, **b = NULL, **c = NULL;
	struct timeval fin, ini;

	printf("Word size: %ld bits\n", 8 * sizeof(float));

	if (argc != 2)
	{
		printf("Error: ./%s <matrix size>\n", argv[0]);
		return -1;
	}
	n = atoi(argv[1]);
	if (!(a = generateMatrix(n)) || !(b = generateMatrix(n)) || !(c=generateEmptyMatrix(n)))
	{
		freeMatrices(a, b, c);
		return -1;
	}

	gettimeofday(&ini, NULL);
	/* Main computation */
	multiply(a, b, c, n);
	/* End of computation */
	gettimeofday(&fin, NULL);

	printf("Execution time: %f\n", ((fin.tv_sec * 1000000 + fin.tv_usec) - (ini.tv_sec * 1000000 + ini.tv_usec)) * 1.0 / 1000000.0);

	freeMatrices(a, b, c);
	return 0;
}

void multiply(float **a, float **b, float **c, int n)
{
	for (int i = 0; i < n; i++)
	{
		#pragma omp parallel for
			for (int j = 0; j < n; j++)
			{
				c[i][j] = 0;
				for(int k = 0; k < n; k++)
				{
					c[i][j] += a[i][k] * b[k][j];
				}
			}
	}
}

void freeMatrices(float **a, float **b, float **c)
{
	if(a) freeMatrix(a);
	if(b) freeMatrix(b);
	if(c) freeMatrix(c);
}