set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "out1/slow_fast_time.png"
plot "out1/slow_fast_time.dat" using 1:2 with lines lw 2 title "slow", \
     "out1/slow_fast_time.dat" using 1:3 with lines lw 2 title "fast"
replot
quit