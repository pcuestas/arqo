
#!/bin/bash

# inicializar variables

T=1000000
MAX_STEPS=20

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

for (( i=0; i<= MAX_STEPS; i +=1)); do
    echo "      Step $i, T=$T"
    for ((j = 0 ; j <= REP ; j += 1));do
        echo "      Iteration $j"
        inf=`echo "0.8*$T" | bc`
        sup=`echo "1.2*$T" | bc`
        serieInf=$(./pescalar_serie $inf | grep 'Tiempo' | awk '{print $2}')
        paralelInf=$(./pescalar_par3 $inf | grep 'Tiempo' | awk '{print $2}')
        serieSup=$(./pescalar_serie $sup | grep 'Tiempo' | awk '{print $2}')
        paralelSup=$(./pescalar_par3 $sup | grep 'Tiempo' | awk '{print $2}')

        echo "$T	$serieInf   $serieSup   $paralelInf $paralelSup" >> $fAUX
    done

    
    
    medias=$(grep -w $T $fAUX | awk  '{ sI += $2; sS+=$3; pI += $4; pS += $5; n++ } END {printf "%s\t%s\t%s\t%s", sI/n, sS/n, pI/n, pS/n}')

    
    echo "$T    ${medias[0]}  ${medias[1]}  ${medias[2]}  ${medias[3]}" >> $fDAT
  
    echo "NO FUNCIONAN LAS MEDIAS" ##REVISAR MEDIAS !!!!!
    echo "${medias[0]} ${medias[2]} ${medias[1]}  ${medias[3]} "


    if [[ ${medias[0]} -lt ${medias[2]} ]] && [[ ${medias[1]} -gt ${medias[3]} ]]
    then
        T=`echo "$T-$INCR_FACTOR*$T" | bc`
    else
        T=`echo "$T+$INCR_FACTOR*$T" | bc`
    fi

    

done

