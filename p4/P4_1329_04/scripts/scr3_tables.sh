#!/bin/bash


## Authors: Pablo Cuesta Sierra and Álvaro Zamanillo Sáez
## Tests for exercise 3 initial tables

# inicializar variables 

T=5000
THREADS_MAX=4 
MAX_REP=4

DAT_DIR="../outputs/out3/tables/"
SRC_DIR="../src/"

MULT="${SRC_DIR}multiplication"
LOOP1="${SRC_DIR}multiplication_loop1"
LOOP2="${SRC_DIR}multiplication_loop2"
LOOP3="${SRC_DIR}multiplication_loop3"

fAUX="${DAT_DIR}aux.dat"
fDAT="${DAT_DIR}table.dat"

TAB="\t"


# borrar el fichero DAT y el fichero PNGtipo
rm -f $fAUX $fDAT
mkdir -p ${DAT_DIR}

echo "Running multiplication..."

echo -e "threads${TAB}serial${TAB}loop1${TAB}loop2${TAB}loop3" > $fDAT

mult=$($MULT $T | grep 'time' | awk '{print $3}')
for ((rep=0; rep<MAX_REP; rep++));do
    echo "rep: $rep out of $MAX_REP"
    for ((j = 1 ; j <= THREADS_MAX ; j += 1));do
        echo "      Threads: $j"
        export OMP_NUM_THREADS=$j
        #echo "T=$T"
        loop1=$($LOOP1 $T | grep 'time' | awk '{print $3}')
        loop2=$($LOOP2 $T | grep 'time' | awk '{print $3}')
        loop3=$($LOOP3 $T | grep 'time' | awk '{print $3}')

        echo -e "$j${TAB}$mult${TAB}$loop1${TAB}$loop2${TAB}$loop3" >> $fAUX
    done
done

#calculate means

for N in $(awk '{ print $1 }' $fAUX | sort -n | uniq); do
	means=$(grep -w $N $fAUX | awk '{ t0 += $2; t1 += $3; t2 += $4; t3 += $5; n++ } END { printf "%s\t%s\t%s\t%s\n", t0/n, t1/n, t2/n, t3/n }')
    echo -e "$N${TAB}$means" >> $fDAT
done

