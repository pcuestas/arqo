set title "Multiplication times: parallel vs serial"
set ylabel "Execution time (s)"
set xlabel "Matrix Size (N)"
set key top left
set grid
set term png
set output "t_fig.png"
plot "time_means.dat" using 1:2 with lines lw 2 title "Serial", \
     "time_means.dat" using 1:3 with lines lw 2 title 'Parallel 2 threads',\
     "time_means.dat" using 1:4 with lines lw 2 title 'Parallel 4 threads',\
     "time_means.dat" using 1:5 with lines lw 2 title 'Parallel 6 threads'
replot

set title "Multiplication time ratios: (serial time) / (parallel time)"
set ylabel "Time ratio: serial/parallel"
set xlabel "Matrix Size (N)"
set key right bottom
set grid
set yrange [0:5]
set term png
set output "r_fig.png"
plot "ratios.dat" using 1:2 with lines lw 2 title 'Ratio 2 threads',\
     "ratios.dat" using 1:3 with lines lw 2 title 'Ratio 4 threads',\
     "ratios.dat" using 1:4 with lines lw 2 title 'Ratio 6 threads'
replot
quit