#!/bin/bash

# max function. use: max "number"
max () {
    echo `echo "($1 > $2)*($1) + ($1 <= $2)*($2)" | bc`
}

# inicializar variables

REP=50

DAT_DIR="../outputs/out4/"
SRC_DIR="../src/"
TAB="\t"

SERIAL="${SRC_DIR}pi_serie"
PARALLEL="${SRC_DIR}pi_par"
DECIMALS=6 #number of decimal digits

fDAT="${DAT_DIR}pi_.dat"
fDAT2="${DAT_DIR}pi.dat"
fAUX="${DAT_DIR}aux.dat"
OUTPUT_FILE="${DAT_DIR}out_text.dat"
#fPNG="${DAT_DIR}threshold.png"

# borrar el fichero DAT y el fichero PNG
rm -f $fAUX $fDAT $fDAT2
mkdir -p ${DAT_DIR}

# generar el fichero DAT vacío
touch $fDAT $fAUX

echo "Running pi_versions"

# Realizar iteraciones con las distintas versiones


for ((j = 0 ; j < REP ; j += 1));do
    echo "  Iteration $j"

    #Serial version
    ${SERIAL} > ${OUTPUT_FILE}
    time=$(cat ${OUTPUT_FILE} | grep 'Tiempo' | awk '{print $2}')
    res=$(cat ${OUTPUT_FILE} | grep 'pi' | awk '{print $3}')
        
    echo -e "pi_serie${TAB}$time${TAB}$res" >> $fAUX

    #Parallel versions
    for (( Ver=1; Ver<=7; Ver+= 1)); do
        ${PARALLEL}$Ver > ${OUTPUT_FILE}
        time=$(cat ${OUTPUT_FILE} | grep 'Tiempo' | awk '{print $2}')
        res=$(cat ${OUTPUT_FILE} | grep 'pi' | awk '{print $3}')
        
        echo -e "pi_par$Ver${TAB}$time${TAB}$res" >> $fAUX
    done
done

# calculate the means
for N in $(awk '{ print $1 }' $fAUX | sort -n | uniq); do
	means=$(grep -w $N $fAUX | awk '{ time += $2; n++ } END { printf "%s\n", time/n }')
	res=$(grep -w $N $fAUX | head -1 | awk '{print $3}')
    echo -e "$N${TAB}$means${TAB}$res" >> $fDAT
done


echo -e "Program${TAB}Average exec. time (s)${TAB}Speedup${TAB}Result" > $fAUX

t0=$(grep -w pi_serie $fDAT | head -1 | awk '{print $2}')

while read n t res;do
    echo -e "$n${TAB}$t${TAB}$(echo "scale=$DECIMALS;$t0/$t" | bc)${TAB}${res}" >> $fAUX
done < $fDAT

#reordenamiento de lineas
grep -w "Program" $fAUX > $fDAT2
grep -w "pi_serie" $fAUX >> $fDAT2
grep "pi_par" $fAUX >> $fDAT2


rm -f ${OUTPUT_FILE}
