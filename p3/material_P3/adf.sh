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
