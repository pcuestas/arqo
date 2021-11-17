set title "Cache read misses"
set ylabel "Number of misses" font ",11"
set xlabel "Matrix Size (N)" font ",11"
set key font ",11"
set tics font ",11"
set key outside
set key right top Left
set grid
set term pngcairo dashed size 800,400
set output "out4/asoc/lectura.png"
plot "out4/asoc/1.dat" using 1:2 with lines lt rgb "#0000FF00"  dt 1 lw 2 title "D1mr regular mult. - ways: 1", \
     "out4/asoc/1.dat" using 1:4 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mr transposed mult. - ways: 1", \
	"out4/asoc/2.dat" using 1:2 with lines lt rgb "#000000FF"   dt 1 lw 2 title "D1mr regular mult. - ways: 2", \
     "out4/asoc/2.dat" using 1:4 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mr transposed mult. - ways: 2", \
	"out4/asoc/4.dat" using 1:2 with lines lt rgb "#00800080" dt "-" lw 2 title "D1mr regular mult. - ways: 4", \
     "out4/asoc/4.dat" using 1:4 with lines lt rgb "#00800080" dt "." lw 2 title "D1mr transposed mult. - ways: 4", \
	"out4/asoc/8.dat" using 1:2 with lines lt rgb "#90FF0000"    dt 1 lw 2 title "D1mr regular mult. - ways: 8", \
     "out4/asoc/8.dat" using 1:4 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mr transposed mult. - ways: 8"
replot

set title "Cache write misses"
set ylabel "Number of misses"
set xlabel "Matrix size (N)"
set key right top Left
set grid
set term pngcairo dashed size 800,400
set output "out4/asoc/escritura.png"
plot "out4/asoc/1.dat" using 1:3 with lines lt rgb "#9000FF00"  dt 1 lw 2 title "D1mw regular mult. - ways: 1", \
     "out4/asoc/1.dat" using 1:5 with lines lt rgb "#0000FF00"  dt 2 lw 2 title "D1mw transposed mult. - ways: 1", \
	"out4/asoc/2.dat" using 1:3 with lines lt rgb "#900000FF"   dt 1 lw 2 title "D1mw regular mult. - ways: 2", \
     "out4/asoc/2.dat" using 1:5 with lines lt rgb "#000000FF"   dt 2 lw 2 title "D1mw transposed mult. - ways: 2", \
	"out4/asoc/4.dat" using 1:3 with lines lt rgb "#00800080" dt "-" lw 2 title "D1mw regular mult. - ways: 4", \
     "out4/asoc/4.dat" using 1:5 with lines lt rgb "#00800080" dt "." lw 2 title "D1mw transposed mult. - ways: 4", \
	"out4/asoc/8.dat" using 1:3 with lines lt rgb "#90FF0000"    dt 1 lw 2 title "D1mw regular mult. - ways: 8", \
     "out4/asoc/8.dat" using 1:5 with lines lt rgb "#00FF0000"    dt 2 lw 2 title "D1mw transposed mult. - ways: 8"
replot
quit