#!/bin/bash


# Pablo Cuesta Sierra, Álvaro Zamanillo Sáez
# Script for the exercise 2

# inicializar variables
P=4
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))

L1sizes=(1024 2048 4096 8192)
LLsize=8388608

fPNGread=out2/cache_lectura.png
fPNGwrite=out2/cache_escritura.png

# borrar el fichero DAT y el fichero PNG
rm -f $fPNGread $fPNGwrite

# directory for output files
mkdir out2

echo "Running slow and fast..."

fileAux=auxfile.dat

for ((SLone=1024;SLone<=8192;SLone=SLone*2)); do 
	currentFile=out2/$SLone.dat
	valgrindOptions="--I1=$SLone,1,64 --D1=$SLone,1,64 --LL=$LLsize,1,64"
	rm -f $currentFile
	touch $currentFile

	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "size $SLone - N: $N / $Nfinal..."

		valgrind --tool=cachegrind --cachegrind-out-file=$fileAux $valgrindOptions ./slow $N &> /dev/null
		slowValues=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		rm -f $fileAux

		valgrind --tool=cachegrind --cachegrind-out-file=$fileAux $valgrindOptions ./fast $N &> /dev/null
		fastValues=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		rm -f $fileAux

		echo "$N	$slowValues	$fastValues" >> $currentFile
	done
done

