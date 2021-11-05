set title "Cache read misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right top
set grid
set term png
set output "out2/cache_lectura.png"
plot "out2/1024.dat" using 1:2 with lines lw 2 title "D1mr slow - Level 1: 1024B", \
     "out2/1024.dat" using 1:4 with lines lw 2 title "D1mr fast - Level 1: 1024B", \
	"out2/2048.dat" using 1:2 with lines lw 2 title "D1mr slow - Level 1: 2048B", \
     "out2/2048.dat" using 1:4 with lines lw 2 title "D1mr fast - Level 1: 2048B", \
	"out2/4096.dat" using 1:2 with lines lw 2 title "D1mr slow - Level 1: 4096B", \
     "out2/4096.dat" using 1:4 with lines lw 2 title "D1mr fast - Level 1: 4096B", \
	"out2/8192.dat" using 1:2 with lines lw 2 title "D1mr slow - Level 1: 8192B", \
     "out2/8192.dat" using 1:4 with lines lw 2 title "D1mr fast - Level 1: 8192B"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Cache size (B)"
set key right top
set grid
set term png
set output "out2/cache_escritura.png"
plot "out2/1024.dat" using 1:3 with lines lw 2 title "D1mw slow - Level 1: 1024B", \
     "out2/1024.dat" using 1:5 with lines lw 2 title "D1mw fast - Level 1: 1024B", \
	"out2/2048.dat" using 1:3 with lines lw 2 title "D1mw slow - Level 1: 2048B", \
     "out2/2048.dat" using 1:5 with lines lw 2 title "D1mw fast - Level 1: 2048B", \
	"out2/4096.dat" using 1:3 with lines lw 2 title "D1mw slow - Level 1: 4096B", \
     "out2/4096.dat" using 1:5 with lines lw 2 title "D1mw fast - Level 1: 4096B", \
	"out2/8192.dat" using 1:3 with lines lw 2 title "D1mw slow - Level 1: 8192B", \
     "out2/8192.dat" using 1:5 with lines lw 2 title "D1mw fast - Level 1: 8192B"
replot
quit