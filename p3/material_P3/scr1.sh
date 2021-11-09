# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
Ninicio=1024
Npaso=1024
Nfinal=16384
NMAXiterations=30
fDATaux=out1/slow_fast_time_aux.dat
fDAT=out1/slow_fast_time.dat
fPNG=out1/slow_fast_time.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG $fDATaux

# generar el fichero DAT vacío
touch $fDAT

echo "Running slow and fast..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);
for i in $(seq 1 1 $NMAXiterations); do 
	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo " iteration $i - N: $N / $Nfinal..."
		
		# ejecutar los programas slow y fast consecutivamente con tamaño de matriz N
		# para cada uno, filtrar la línea que contiene el tiempo y seleccionar la
		# tercera columna (el valor del tiempo). Dejar los valores en variables
		# para poder imprimirlos en la misma línea del fichero de datos
		slowTime=$(./slow $N | grep 'time' | awk '{print $3}')
		fastTime=$(./fast $N | grep 'time' | awk '{print $3}')

		echo "$N	$slowTime	$fastTime" >> $fDATaux
	done
done

#calculate the means
for N in $(awk '{ print $1 }' $fDATaux | sort -n | uniq); do
		mean=$(grep -w $N $fDATaux | awk '{ slow += $2; fast += $3; n++ } END { printf "%s\t%s\n", slow/n, fast/n }')
		echo "$N	$mean" >> $fDAT
done

echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG"
plot "$fDAT" using 1:2 with lines lw 2 title "slow", \
     "$fDAT" using 1:3 with lines lw 2 title "fast"
replot
quit
END_GNUPLOT
