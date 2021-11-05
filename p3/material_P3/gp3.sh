set title "Multiplications Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "out3/mult_time.png"
plot "out3/mult.dat" using 1:2 with lines lw 2 title "Regular multiplication", \
     "out3/mult.dat" using 1:5 with lines lw 2 title "Transposed multiplication"
replot

set title "Number of misses in multiplication programs"
set ylabel "Number of misses"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "out3/mult_cache.png"
plot "out3/mult.dat" using 1:3 with lines lw 2 title "D1mr regular multiplication", \
     "out3/mult.dat" using 1:4 with lines lw 2 title "D1mw regular multiplication", \
		 "out3/mult.dat" using 1:6 with lines lw 2 title "D1mr transposed multiplication", \
     "out3/mult.dat" using 1:7 with lines lw 2 title "D1mw transposed multiplication"
replot
quit