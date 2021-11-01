#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "arqo3.h"

void free_all(tipo**m1,tipo**m2,tipo**m3);
void compute(tipo **m1, tipo **m2, tipo **m3, int n);
void transpose(tipo **m, int n);

int main(int argc, char *argv[]){


    tipo **m1=NULL, **m2=NULL, **m3=NULL;
    int n;
    struct timeval fin,ini;

    if(argc!=2){
        fprintf(stderr,"Error: ./%s <matrix size>\n", argv[0]);
    }

    n=atoi(argv[1]);
    m1=generateMatrix(n);
    m2=generateMatrix(n);
    m3=generateEmptyMatrix(n);

    if(!m1 || !m2 || !m3){
        free_all(m1,m2,m3);
        return -1;
    }

    gettimeofday(&ini,NULL);

    transpose(m2,n);
    compute(m1,m2,m3,n);

    gettimeofday(&fin,NULL);
	printf("Execution time: %f\n", ((fin.tv_sec*1000000+fin.tv_usec)-(ini.tv_sec*1000000+ini.tv_usec))*1.0/1000000.0);
	printf("Result: \n");

    free_all(m1,m2,m3);
    return 0;
}


void compute(tipo **m1, tipo **m2, tipo **m3, int n){
    int i,j,k;

    for(i=0;i<n;i++){
        for(j=0;j<n;j++){
            for(k=0;k<n;k++){
                 m3[i][j]+=m1[i][k]*m2[j][k];
            }
           
        }
    }
}

void free_all(tipo **m1, tipo **m2,tipo**m3){
    if(m1)
        freeMatrix(m1);
    if(m2)
        freeMatrix(m2);
    if(m3)
        freeMatrix(m3);
}

void transpose(tipo **m, int n){
    int i,j;
    tipo aux;

    for(i=0;i<n;i++){
        for(j=i;j<n;j++){
            aux=m[i][j];
            m[i][j]=m[j][i];
            m[j][i]=aux;
        }
        
    }
}