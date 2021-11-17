set title "Cache read misses"
set ylabel "Number of misses" font ",11"
set xlabel "Matrix size (N)" font ",11"
set key font ",11"
set tics font ",11"
set key outside
set key right top Left
set grid
set term pngcairo dashed size 800,400
set output "../outputs/out2/cache_lectura.png"
plot "../outputs/out2/1024.dat" using 1:2 with lines lt rgb "#0000FF00"  dt 1 lw 2 title "D1mr slow - Level 1: 1024B", \
     "../outputs/out2/1024.dat" using 1:4 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mr fast - Level 1: 1024B", \
	"../outputs/out2/2048.dat" using 1:2 with lines lt rgb "#000000FF"   dt 1 lw 2 title "D1mr slow - Level 1: 2048B", \
     "../outputs/out2/2048.dat" using 1:4 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mr fast - Level 1: 2048B", \
	"../outputs/out2/4096.dat" using 1:2 with lines lt rgb "#00800080" dt 1 lw 2 title "D1mr slow - Level 1: 4096B", \
     "../outputs/out2/4096.dat" using 1:4 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mr fast - Level 1: 4096B", \
	"../outputs/out2/8192.dat" using 1:2 with lines lt rgb "#00FF0000"    dt 1 lw 2 title "D1mr slow - Level 1: 8192B", \
     "../outputs/out2/8192.dat" using 1:4 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mr fast - Level 1: 8192B"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Matrix size (N)"
set key right top Left
set grid
set term pngcairo dashed
set output "../outputs/out2/cache_escritura.png"
plot "../outputs/out2/1024.dat" using 1:3 with lines lt rgb "#9000FF00"  dt 1 lw 2 title "D1mw slow - Level 1: 1024B", \
     "../outputs/out2/1024.dat" using 1:5 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mw fast - Level 1: 1024B", \
	"../outputs/out2/2048.dat" using 1:3 with lines lt rgb "#900000FF"   dt 1 lw 2 title "D1mw slow - Level 1: 2048B", \
     "../outputs/out2/2048.dat" using 1:5 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mw fast - Level 1: 2048B", \
	"../outputs/out2/4096.dat" using 1:3 with lines lt rgb "#90800080" dt 1 lw 2 title "D1mw slow - Level 1: 4096B", \
     "../outputs/out2/4096.dat" using 1:5 with lines lt rgb "#00800080" dt 2 lw 2 title "D1mw fast - Level 1: 4096B", \
	"../outputs/out2/8192.dat" using 1:3 with lines lt rgb "#90FF0000"    dt 1 lw 2 title "D1mw slow - Level 1: 8192B", \
     "../outputs/out2/8192.dat" using 1:5 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mw fast - Level 1: 8192B"
replot
quit