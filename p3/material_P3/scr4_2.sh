# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=2
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))

#L1sizes=(1024 2048 4096 8192)
LLsize=8388608
L1size=2048

fPNGread=out4/block/$L1size/cache_lectura.png
fPNGwrite=out4/block/$L1size/cache_escritura.png

# delete the directory
rm -f -r out4/block/$L1size

# directory for output files
mkdir out4
mkdir out4/block
mkdir out4/block/$L1size

echo "Running slow and fast..."

fileAux=out4/block/$L1size/auxfile.dat

for ((LINE=32;LINE<=256;LINE=LINE*2)); do 
	currentFile=out4/block/$L1size/$LINE.dat
	valgrindOptions="--I1=$L1size,1,$LINE --D1=$L1size,1,$LINE --LL=$LLsize,1,$LINE"
	rm -f $currentFile
	touch $currentFile

	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "line size $LINE - N: $N / $Nfinal..."

		valgrind --tool=cachegrind --cachegrind-out-file=$fileAux $valgrindOptions ./slow $N &> /dev/null
		slowValues=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		rm -f $fileAux

		valgrind --tool=cachegrind --cachegrind-out-file=$fileAux $valgrindOptions ./fast $N &> /dev/null
		fastValues=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		rm -f $fileAux

		echo "$N	$slowValues	$fastValues" >> $currentFile
	done
done

