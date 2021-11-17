set title "Cache read misses"
set ylabel "Number of misses" font ",11"
set xlabel "Matrix size (N)" font ",11"
set key font ",11"
set tics font ",11"
set key outside
set key right top Left
set grid
set term pngcairo dashed size 800,400
set output "cache_lectura.png"
plot "32.dat" using 1:2 with lines lt rgb "#0000FF00"  dt 1 lw 2 title "D1mr regular mult. - Block Size: 32", \
     "32.dat" using 1:4 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mr transposed mult. - Block Size: 32", \
	"64.dat" using 1:2 with lines lt rgb "#000000FF"   dt 1 lw 2 title "D1mr regular mult. - Block Size: 64", \
     "64.dat" using 1:4 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mr transposed mult. - Block Size: 64", \
	"128.dat" using 1:2 with lines lt rgb "#00800080" dt 1 lw 2 title "D1mr regular mult. - Block Size: 128", \
     "128.dat" using 1:4 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mr transposed mult. - Block Size: 128", \
	"256.dat" using 1:2 with lines lt rgb "#00FF0000"    dt 1 lw 2 title "D1mr regular mult. - Block Size: 256", \
     "256.dat" using 1:4 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mr transposed mult. - Block Size: 256"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Matrix size (N)" font ",10"
set key right top Left
set grid
set term pngcairo dashed
set output "cache_escritura.png"
plot "32.dat" using 1:3 with lines lt rgb "#9000FF00"  dt 1 lw 2 title "D1mw regular mult. - Block Size: 32", \
     "32.dat" using 1:5 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mw transposed mult. - Block Size: 32", \
	"64.dat" using 1:3 with lines lt rgb "#900000FF"   dt 1 lw 2 title "D1mw regular mult. - Block Size: 64", \
     "64.dat" using 1:5 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mw transposed mult. - Block Size: 64", \
	"128.dat" using 1:3 with lines lt rgb "#90800080" dt 1 lw 2 title "D1mw regular mult. - Block Size: 128", \
     "128.dat" using 1:5 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mw transposed mult. - Block Size: 128", \
	"256.dat" using 1:3 with lines lt rgb "#90FF0000"    dt 1 lw 2 title "D1mw regular mult. - Block Size: 256", \
     "256.dat" using 1:5 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mw transposed mult. - Block Size: 256"
replot
quit