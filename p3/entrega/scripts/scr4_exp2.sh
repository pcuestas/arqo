#!/bin/bash

# Pablo Cuesta Sierra, Álvaro Zamanillo Sáez
# Script for the exercise 4, experiment 2

# inicializar variables
P=2
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))

LLsize=8388608
L1size=2048


fPNGread=out4/BlockSize_$L1size/cache_lectura.png
fPNGwrite=out4/BlockSize_$L1size/cache_escritura.png

# delete the directory
rm -f -r out4/BlockSize_$L1size

# directory for output files
mkdir out4
mkdir out4/BlockSize_$L1size

echo "Running slow and fast..."

fileAux=out4/BlockSize_$L1size/auxfile.dat

for ((BlockSize=32;BlockSize<=256;BlockSize=BlockSize*2)); do 
	currentFile=out4/BlockSize_$L1size/$BlockSize.dat
	valgrindOptions="--I1=$L1size,1,$BlockSize --D1=$L1size,1,$BlockSize --LL=$LLsize,1,$BlockSize"
	rm -f $currentFile
	touch $currentFile

	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "asociativity $BlockSize - N: $N / $Nfinal..."

		valgrind --tool=cachegrind --cachegrind-out-file=$fileAux $valgrindOptions ./slow $N &> /dev/null
		slowValues=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		rm -f $fileAux

		valgrind --tool=cachegrind --cachegrind-out-file=$fileAux $valgrindOptions ./fast $N &> /dev/null
		fastValues=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		rm -f $fileAux

		echo "$N	$slowValues	$fastValues" >> $currentFile
	done
done
