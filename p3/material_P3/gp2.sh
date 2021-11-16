set title "Cache read misses"
set ylabel "Number of misses" font ",11"
set xlabel "Matrix size (N)" font ",11"
set key font ",11"
set tics font ",11"
set key outside
set key right top Left
set grid
set term pngcairo dashed size 800,400
set output "out2/mv_att1/cache_lectura.png"
plot "out2/mv_att1/1024.dat" using 1:2 with lines lt rgb "#0000FF00"  dt 1 lw 2 title "D1mr slow - Level 1: 1024B", \
     "out2/mv_att1/1024.dat" using 1:4 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mr fast - Level 1: 1024B", \
	"out2/mv_att1/2048.dat" using 1:2 with lines lt rgb "#000000FF"   dt 1 lw 2 title "D1mr slow - Level 1: 2048B", \
     "out2/mv_att1/2048.dat" using 1:4 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mr fast - Level 1: 2048B", \
	"out2/mv_att1/4096.dat" using 1:2 with lines lt rgb "#00800080" dt 1 lw 2 title "D1mr slow - Level 1: 4096B", \
     "out2/mv_att1/4096.dat" using 1:4 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mr fast - Level 1: 4096B", \
	"out2/mv_att1/8192.dat" using 1:2 with lines lt rgb "#00FF0000"    dt 1 lw 2 title "D1mr slow - Level 1: 8192B", \
     "out2/mv_att1/8192.dat" using 1:4 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mr fast - Level 1: 8192B"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Matrix size (N)"
set key right top Left
set grid
set term pngcairo dashed
set output "out2/mv_att1/cache_escritura.png"
plot "out2/mv_att1/1024.dat" using 1:3 with lines lt rgb "#9000FF00"  dt 1 lw 2 title "D1mw slow - Level 1: 1024B", \
     "out2/mv_att1/1024.dat" using 1:5 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mw fast - Level 1: 1024B", \
	"out2/mv_att1/2048.dat" using 1:3 with lines lt rgb "#900000FF"   dt 1 lw 2 title "D1mw slow - Level 1: 2048B", \
     "out2/mv_att1/2048.dat" using 1:5 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mw fast - Level 1: 2048B", \
	"out2/mv_att1/4096.dat" using 1:3 with lines lt rgb "#90800080" dt 1 lw 2 title "D1mw slow - Level 1: 4096B", \
     "out2/mv_att1/4096.dat" using 1:5 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mw fast - Level 1: 4096B", \
	"out2/mv_att1/8192.dat" using 1:3 with lines lt rgb "#90FF0000"    dt 1 lw 2 title "D1mw slow - Level 1: 8192B", \
     "out2/mv_att1/8192.dat" using 1:5 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mw fast - Level 1: 8192B"
replot
quit