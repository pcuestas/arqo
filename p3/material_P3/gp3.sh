set title "Multiplications Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size (N)"
set key left top Left
set grid
set term png
set output "out3/mv_att2/mult_time.png"
plot "out3/mv_att2/mult.dat" using 1:2 with lines lw 2 title "Regular multiplication", \
     "out3/mv_att2/mult.dat" using 1:5 with lines lw 2 title "Transposed multiplication"
replot

set title "Number of misses in multiplication programs"
set ylabel "Number of misses" font ",10"
set xlabel "Matrix Size (N)" font ",10"
set key font ",10"
set tics font ",10"
set key outside
set key top right Left
set grid
set term png size 800,400
set output "out3/mv_att2/mult_cache.png"
plot "out3/mv_att2/mult.dat" using 1:3 with lines lw 2 title "D1mr regular multiplication", \
     "out3/mv_att2/mult.dat" using 1:4 with lines lw 2 title "D1mw regular multiplication", \
     "out3/mv_att2/mult.dat" using 1:6 with lines lw 2 title "D1mr transposed multiplication", \
     "out3/mv_att2/mult.dat" using 1:7 with lines lw 2 title "D1mw transposed multiplication"
replot
reset
set title "Number of write misses in multiplication programs"
set ylabel "Number of misses"
set xlabel "Matrix Size (N)"
set key right bottom Left
set grid
set term pngcairo dashed
set output "out3/mv_att2/mult_cache_write.png"
plot "out3/mv_att2/mult.dat" using 1:4 with lines lw 2      lt rgb "#900000FF" title "D1mw regular multiplication", \
     "out3/mv_att2/mult.dat" using 1:7 with lines lw 2 dt 2 lt rgb "#000000FF" title "D1mw transposed multiplication"
replot
quit