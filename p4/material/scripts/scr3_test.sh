#!/bin/bash

# inicializar variables 

P=5
Nmin=$(($P+512))
STEP=64
Nmax=$(($P+1024+512))
REP=4
NUM_THREADS=(2 4 6)

DAT_DIR="../outputs/out3/test/"
SRC_DIR="../src/"

SERIAL="${SRC_DIR}multiplication"
PARALLEL="${SRC_DIR}multiplication_loop3"
DECIMALS=6 #number of decimal digits

fAUX="${DAT_DIR}times.dat"
fTIME="${DAT_DIR}time_means.dat"
fRATIOS="${DAT_DIR}ratios.dat"
fTimePNG="${DAT_DIR}time_figure.png"
fTimeRatios="${DAT_DIR}ratios_figure.png"

TAB="\t"

# borrar el fichero DAT y el fichero PNGtipo
rm -f $fAUX $fTIME $fRATIOS $fTimePNG
mkdir -p ${DAT_DIR}

echo "Running multiplication serial vs parallel..."
    

touch $fAUX 

for ((j = 1 ; j <= REP ; j += 1));do
    echo "iteration $j"
    for (( N = Nmin; N <= Nmax; N += STEP)); do
        string="$N"
        #serial time
        string="${string}${TAB}$($SERIAL $N | grep 'time' | awk '{print $3}')"
        #parallel times
        for threads in ${NUM_THREADS[@]};do
            export OMP_NUM_THREADS=$threads
            string="${string}${TAB}$($PARALLEL $N | grep 'time' | awk '{print $3}')"
        done
        echo -e "$string" >> $fAUX
    done
done

touch $fTIME
# calculate the means
for N in $(awk '{ print $1 }' $fAUX | sort -n | uniq); do
	means=$(grep -w $N $fAUX | awk '{ slow += $2; fast1 += $3; fast2 += $4; fast3 += $5; n++ } END { printf "%s\t%s\t%s\t%s\n", slow/n, fast1/n, fast2/n, fast3/n }')
	echo -e "$N${TAB}$means" >> $fTIME
done

touch $fRATIOS
# calculate the ratios
while read n ser par; do
    ratios="$n"
    for value in ${par[@]};do
        ratios="${ratios}${TAB}$(echo "scale=$DECIMALS;$ser/$value" | bc)"
    done
    echo -e "$ratios" >> $fRATIOS
done < $fTIME


gnuplot << END_GNUPLOT
set title "Multiplication times: parallel vs serial"
set ylabel "Execution time (s)"
set xlabel "Matrix Size (N)"
set key top left
set grid
set term png
set output "$fTimePNG"
plot "$fTIME" using 1:2 with lines lw 2 title "Serial", \
     "$fTIME" using 1:3 with lines lw 2 title 'Parallel 2 threads',\
     "$fTIME" using 1:4 with lines lw 2 title 'Parallel 4 threads',\
     "$fTIME" using 1:5 with lines lw 2 title 'Parallel 6 threads'
replot

set title "Multiplication time ratios: (serial time) / (parallel time)"
set ylabel "Time ratio: serial/parallel"
set xlabel "Matrix Size (N)"
set key right bottom
set grid
set term png
set output "$fTimeRatios"
plot "$fRATIOS" using 1:2 with lines lw 2 title 'Ratio 2 threads',\
     "$fRATIOS" using 1:3 with lines lw 2 title 'Ratio 4 threads',\
     "$fRATIOS" using 1:4 with lines lw 2 title 'Ratio 6 threads'
replot

quit
END_GNUPLOT
