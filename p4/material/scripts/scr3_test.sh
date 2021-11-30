
#!/bin/bash

# inicializar variables 

P=5
Nmin=$(($P+512))
STEP=64
Nmax=$(($P+1024+512))
REP=4  

DAT_DIR="../outputs/out3/"
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
    
export OMP_NUM_THREADS=4

touch $fAUX

for ((j = 1 ; j <= REP ; j += 1));do
    echo "iteration $j"
    for (( N = Nmin; N <= Nmax; N += STEP)); do
        serial_time=$($SERIAL $N | grep 'time' | awk '{print $3}')
        parallel_time=$($PARALLEL $N | grep 'time' | awk '{print $3}')

        echo -e "$N${TAB}${serial_time}${TAB}${parallel_time}" >> $fAUX
    done
done

touch $fTIME
# calculate the means
for N in $(awk '{ print $1 }' $fAUX | sort -n | uniq); do
	means=$(grep -w $N $fAUX | awk '{ slow += $2; fast += $3; n++ } END { printf "%s\t%s\n", slow/n, fast/n }')
	echo -e "$N${TAB}$means" >> $fTIME
done

touch $fRATIOS
# calculate the ratios
while read n ser par; do
    ratio=$(echo "scale=$DECIMALS;$ser/$par" | bc)
    echo -e "${n}${TAB}$ratio" >> $fRATIOS
done < $fTIME


gnuplot << END_GNUPLOT
set title "Multiplication times: parallel vs serial"
set ylabel "Execution time (s)"
set xlabel "Matrix Size (N)"
set key right bottom
set grid
set term png
set output "$fTimePNG"
plot "$fTIME" using 1:2 with lines lw 2 title "Serial", \
     "$fTIME" using 1:3 with lines lw 2 title "Parallel"
replot

set title "Multiplication time ratios: parallel/serial"
set ylabel "Time ratio: parallel/serial"
set xlabel "Matrix Size (N)"
set key right bottom
set grid
set term png
set output "$fTimeRatios"
plot "$fRATIOS" using 1:2 with lines lw 2 title "Ratio"
replot

quit
END_GNUPLOT
