# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=4
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))

L1sizes=(1024 2048 4096 8192)
LLsize=8388608

fDAT=e2.dat
fPNGread=cache_lectura.png
fPNGwrite=cache_escritura.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNGread $fPNGwritew
rm -r outputs

touch $fDAT

# directory for output files
mkdir outputs

echo "Running slow and fast..."

for ((SLone=1024;SLone<=8192;SLone=SLone*2)); do 
	currentFile=outputs/$SLone.dat
	valgrindOptions="--I1=$SLone,1,64 --D1=$SLone,1,64 --LL=$LLsize,1,64"
	rm -f $currentFile
	touch $currentFile

	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "size $SLone - N: $N / $Nfinal..."

		file_slow=outputs/$SLone.$N.slow.dat
		file_fast=outputs/$SLone.$N.fast.dat

		valgrind --tool=cachegrind --cachegrind-out-file=$file_slow $valgrindOptions ./slow $N &> /dev/null
		valgrind --tool=cachegrind --cachegrind-out-file=$file_fast $valgrindOptions ./fast $N &> /dev/null
		
		slowValues=$(cg_annotate $file_slow | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
		fastValues=$(cg_annotate $file_fast | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')

		echo "$N	$slowValues	$fastValues" >> $currentFile
	done
	
	#pasar todos los datos a un mismo fichero
	while read line; do
		echo -e "${SLone}\t$line" >> $fDAT
	done < $currentFile

done

echo "exit"


# echo "Generating plot..."
# # llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# # estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Cache read misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right bottom
set grid
set term png
set output "$fPNGread"
plot "$fDAT" using 1:3  title "D1mr slow", \
     "$fDAT" using 1:5  title "D1mr fast"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right bottom
set grid
set term png
set output "$fPNGwrite"
plot "$fDAT" using 1:4  title "D1mw slow", \
     "$fDAT" using 1:6  title "D1mw fast"
replot
quit
END_GNUPLOT