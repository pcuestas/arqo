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


gnuplot << END_GNUPLOT
set title "Cache read misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right top
set grid
set term pngcairo dashed
set output "$fPNGread"
plot "out2/1024.dat" using 1:2 with lines lt rgb "#0000FF00"  dt 1 lw 2 title "D1mr slow - Level 1: 1024B", \
  "out2/1024.dat" using 1:4 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mr fast - Level 1: 1024B", \
	"out2/2048.dat" using 1:2 with lines lt rgb "#000000FF"   dt 1 lw 2 title "D1mr slow - Level 1: 2048B", \
  "out2/2048.dat" using 1:4 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mr fast - Level 1: 2048B", \
	"out2/4096.dat" using 1:2 with lines lt rgb "#00800080" dt 1 lw 2 title "D1mr slow - Level 1: 4096B", \
  "out2/4096.dat" using 1:4 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mr fast - Level 1: 4096B", \
	"out2/8192.dat" using 1:2 with lines lt rgb "#00FF0000"    dt 1 lw 2 title "D1mr slow - Level 1: 8192B", \
  "out2/8192.dat" using 1:4 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mr fast - Level 1: 8192B"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Matrix size (N)"
set key right top
set grid
set term pngcairo dashed
set output "$fPNGwrite"
plot "out2/1024.dat" using 1:3 with lines lt rgb "#9000FF00"  dt 1 lw 2 title "D1mw slow - Level 1: 1024B", \
  "out2/1024.dat" using 1:5 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mw fast - Level 1: 1024B", \
	"out2/2048.dat" using 1:3 with lines lt rgb "#900000FF"   dt 1 lw 2 title "D1mw slow - Level 1: 2048B", \
  "out2/2048.dat" using 1:5 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mw fast - Level 1: 2048B", \
	"out2/4096.dat" using 1:3 with lines lt rgb "#90800080" dt 1 lw 2 title "D1mw slow - Level 1: 4096B", \
  "out2/4096.dat" using 1:5 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mw fast - Level 1: 4096B", \
	"out2/8192.dat" using 1:3 with lines lt rgb "#90FF0000"    dt 1 lw 2 title "D1mw slow - Level 1: 8192B", \
  "out2/8192.dat" using 1:5 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mw fast - Level 1: 8192B"
replot
quit
END_GNUPLOT