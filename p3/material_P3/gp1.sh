set title "Slow-Fast Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size (N)"
set key right bottom
set grid
set term png
set output "out1/mv_att4/slow_fast_time.png"
plot "out1/mv_att4/slow_fast_time.dat" using 1:2 with lines lw 2 title "slow", \
     "out1/mv_att4/slow_fast_time.dat" using 1:3 with lines lw 2 title "fast"
replot
quit