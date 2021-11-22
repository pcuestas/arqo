
#!/bin/bash

ceil () {
    echo `echo "($1 > $1/1)*($1/1 + 1) + ($1 == $1/1)*($1/1)" | bc`
}

# inicializar variables

Tmin=700000
STEP=50000
Tmax=1500000

SERIAL="../src/pescalar_serie"
PARALLEL="../src/pescalar_par3"

fDAT=out2/threshold.dat
fAUX=out2/aux.dat

REP=20
INCR_FACTOR=0.1
# borrar el fichero DAT y el fichero PNG
rm -f $fAUX $fDAT

# generar el fichero DAT vacío
touch $fDAT $fAUX

# delete the directory
rm -f -r out2

# directory for output files
mkdir out2

echo "Running parallel and serial.."

for (( T=Tmin; T <= Tmax; T += STEP)); do
    echo "T=$T"
    for ((j = 0 ; j <= REP ; j += 1));do
        echo "      Iteration $j"
        inf=`ceil "0.8*$T"`
        sup=`ceil "1.2*$T"`
        serieInf=$($SERIAL $inf | grep 'Tiempo' | awk '{print $2}')
        paralelInf=$($PARALLEL $inf | grep 'Tiempo' | awk '{print $2}')
        serieSup=$($SERIAL $sup | grep 'Tiempo' | awk '{print $2}')
        paralelSup=$($PARALLEL $sup | grep 'Tiempo' | awk '{print $2}')

        echo "$T	$serieInf	$serieSup	$paralelInf	$paralelSup" >> $fAUX
    done

    
    
    medias=$(grep -w $T $fAUX | awk  '{ sI += $2; sS+=$3; pI += $4; pS += $5; n++ } END {printf "%s\t%s\t%s\t%s", sI/n, sS/n, pI/n, pS/n}')

    echo "$T    ${medias[0]}  ${medias[1]}  ${medias[2]}  ${medias[3]}" >> $fDAT

    

done

