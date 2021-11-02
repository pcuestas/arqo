# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=4
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))

L1sizes=(1024 2048 4096 8192)
LLsize=8388608

fDAT=out2/e2.dat
fPNGread=out2/cache_lectura.png
fPNGwrite=out2/cache_escritura.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNGread $fPNGwritew

touch $fDAT

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
	
	#pasar todos los datos a un mismo fichero
	while read line; do
		echo -e "${SLone}\t$line" >> $fDAT
	done < $currentFile

done

echo "exit"

for ((SLone=1024;SLone<=8192;SLone=SLone*2)); do 
		line=$(grep -w $SLone $fDAT | awk '{ print $0 }')
		echo "$line" >> out2/$N.dat
done

# echo "Generating plot..."
# # llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# # estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Cache read misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right top
set grid
set term png
set output "$fPNGread"
plot "$fDAT" using 1:3  title "D1mr slow", \
     "$fDAT" using 1:5  title "D1mr fast"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right top
set grid
set term png
set output "$fPNGwrite"
plot "$fDAT" using 1:4  title "D1mw slow", \
     "$fDAT" using 1:6  title "D1mw fast"
replot
quit
END_GNUPLOT

for N in $(awk '{ print $1 }' $fDATaux | sort -n | uniq); do 
		rm -f out2/$N.dat
done
