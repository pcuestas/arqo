# Ejemplo script, para P3 arq 2019-2020

#!/bin/bash

# inicializar variables
P=4
Ninicio=$((256+256*P))
Npaso=32
Nfinal=$((256+256*(P+1)))
NMAXiterations=10
fDATaux=out3/mult_aux.dat
fDAT=out3/mult.dat
fPNGTime=out3/mult_time.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNGTime $fDATaux

# generar el fichero DAT vacío
touch $fDAT
touch $fDATaux

echo "Running slow and fast..."

for i in $(seq 1 1 $NMAXiterations); do 
	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo " iteration $i - N: $N / $Nfinal..."
		
		multTime=$(./multiplication $N | grep 'time' | awk '{print $3}')
		mult_tTime=$(./multiplication_t $N | grep 'time' | awk '{print $3}')

		echo "$N	$multTime	$mult_tTime" >> $fDATaux
	done
done

#calculate the means
for N in $(awk '{ print $1 }' $fDATaux | sort -n | uniq); do
		mean=$(grep $N $fDATaux | awk '{ slow += $2; fast += $3; n++ } END { printf "%s\t%s\n", slow/n, fast/n }')
		echo "$N	$mean" >> $fDAT
done

echo "Generating plot..."

gnuplot << END_GNUPLOT
set title "Multiplications Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNGTime"
plot "$fDAT" using 1:2 with lines lw 2 title "Regular multiplication", \
     "$fDAT" using 1:3 with lines lw 2 title "Transposed multiplication"
replot
quit
END_GNUPLOT
