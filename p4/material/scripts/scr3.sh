
#!/bin/bash

# ceiling function. use: ceil "number"
ceil () {
    echo `echo "($1 > $1/1)*($1/1 + 1) + ($1 == $1/1)*($1/1)" | bc`
}

# inicializar variables

Tmin=10000
STEP=400000
Tmax=2000000
REP=4  

DAT_DIR="../outputs/out2/"
SRC_DIR="../src/"

MULT="${SRC_DIR}multiplication"
LOOP1="${SRC_DIR}multiplication_loop1"
LOOP2="${SRC_DIR}multiplication_loop2"
LOOP3="${SRC_DIR}multiplication_loop3"

fDAT="${DAT_DIR}threshold.dat"
fAUX="${DAT_DIR}aux.dat"
fPNG="${DAT_DIR}threshold.png"


# borrar el fichero DAT y el fichero PNG
rm -f $fAUX $fDAT
mkdir -p ${DAT_DIR}

# generar el fichero DAT vacío
touch $fDAT $fAUX

echo "Running multiplication..."

for ((j = 1 ; j <= REP ; j += 1));do
    echo "      Iteration $j"
    for (( T=Tmin; T <= Tmin; T += STEP)); do
        #echo "T=$T"
        inf=`ceil "0.8*$T"`
        sup=`ceil "1.2*$T"`
        serieInf=$($SERIAL $inf | grep 'Tiempo' | awk '{print $2}')
        paralelInf=$($PARALLEL $inf | grep 'Tiempo' | awk '{print $2}')
        serieSup=$($SERIAL $sup | grep 'Tiempo' | awk '{print $2}')
        paralelSup=$($PARALLEL $sup | grep 'Tiempo' | awk '{print $2}')

        echo "$T	$serieInf	$serieSup	$paralelInf	$paralelSup" >> $fAUX
    done

done

for (( T=Tmin; T <= Tmax; T += STEP)); do
    medias=$(grep -w $T $fAUX | awk  '{ sI += $2; sS+=$3; pI += $4; pS += $5; n++ } END {printf "%s\t%s\t%s\t%s", sI/n, sS/n, pI/n, pS/n}')
    echo "$T    ${medias[0]}  ${medias[1]}  ${medias[2]}  ${medias[3]}" >> $fDAT
done

gnuplot << END_GNUPLOT
set title "Serial and parallel comparison"
set ylabel "Execution time (s)"
set xlabel "Vector length (T)"
set key right bottom
set grid
set term pngcairo dashed
set output "$fPNG"
plot "$fDAT" using 1:2 with linespoints lt rgb "blue" dt 2 lw 1 title "Serial - 0.8T", \
     "$fDAT" using 1:4 with linespoints lt rgb "red"  dt 2 lw 1 title "Parallel - 0.8T", \
     "$fDAT" using 1:3 with linespoints lt rgb "blue" dt 1 lw 1 title "Serial - 1.2T", \
     "$fDAT" using 1:5 with linespoints lt rgb "red"  dt 1 lw 1 title "Parallel - 1.2T"
replot
quit
END_GNUPLOT
