
#!/bin/bash

# inicializar variables 

Tmin=2000
STEP=400000
Tmax=2000000
REP=4  

DAT_DIR="../outputs/out3/tables/"
SRC_DIR="../src/"

MULT="${SRC_DIR}multiplication"
LOOP1="${SRC_DIR}multiplication_loop1"
LOOP2="${SRC_DIR}multiplication_loop2"
LOOP3="${SRC_DIR}multiplication_loop3"

fAUX="${DAT_DIR}table.dat"
fPNG="${DAT_DIR}threshold.png"

TAB="\t"


# borrar el fichero DAT y el fichero PNGtipo
rm -f $fAUX
mkdir -p ${DAT_DIR}

# generar el fichero DAT vacío
touch $fAUX

echo "Running multiplication..."

echo -e "threads${TAB}serial${TAB}loop1${TAB}loop2${TAB}loop3" >> $fAUX

for ((j = 1 ; j <= REP ; j += 1));do
    echo "      Threads: $j"
    export OMP_NUM_THREADS=$j
    for (( T=Tmin; T <= Tmin; T += STEP)); do
        #echo "T=$T"
        mult=$($MULT $T | grep 'time' | awk '{print $3}')
        loop1=$($LOOP1 $T | grep 'time' | awk '{print $3}')
        loop2=$($LOOP2 $T | grep 'time' | awk '{print $3}')
        loop3=$($LOOP3 $T | grep 'time' | awk '{print $3}')

        echo -e "$j${TAB}$mult${TAB}$loop1${TAB}$loop2${TAB}$loop3" >> $fAUX
    done
done
