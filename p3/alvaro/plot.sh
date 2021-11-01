set terminal png size 800,500 enhanced font "Helvetica,20"
set output 'output.png'

red = "#FF0000"; green = "#00FF00"; blue = "#0000FF"; skyblue = "#87CEEB";
set yrange [0:20]
set style data histogram
set style histogram cluster gap 1
set style fill solid
set boxwidth 0.9
set xtics format ""
set grid ytics
set title "Cache misses with different sizes"

plot "cache_1024.dat" using 2:xtic(1)  linecolor rgb red,   \
     "cache_1024.dat" using 3 title "Sophia" linecolor rgb blue,   \
     "cache_1024.dat" using 4 title "Jody" linecolor rgb green,    \
     "cache_1024.dat" using 5 title "Christina" linecolor rgb skyblue



# gnuplot << END_GNUPLOT
# set title "Slow-Fast Execution Time"
# set ylabel "Execution time (s)"
# set xlabel "Matrix Size"
# set key right bottom
# set grid
# set term png
# set output "$fPNG"
# plot "$fDAT1" using 1:2 with lines lw 2 title "slow", \
#      "$fDAT1" using 1:3 with lines lw 2 title "fast"
# replot
# quit
# END_GNUPLOT


