#!/bin/bash

# inicializar variables

REP=1

DAT_DIR="../outputs/out5/"
SRC_DIR="../src/"
IMG_DIR="../img/"
TAB="\t"
NUM_IMG_MAX=5
COLUMN_NAMES="Program${TAB}SD${TAB}HD${TAB}FHD${TAB}UHD-4k${TAB}UHD-8k"

SERIAL_BAD="${SRC_DIR}edgeDetector"
SERIAL_GOOD="${SRC_DIR}edgeDetector_optLoops"
PARALLEL="${SRC_DIR}edgeDetector_par"
IMG_PREFIX="${IMG_DIR}img"
DECIMALS=6 #number of decimal digits

MEANS="${DAT_DIR}means.dat"
MEANS2="${DAT_DIR}means2.dat"
TIMES="${DAT_DIR}times.dat"
TIMES2="${DAT_DIR}times2.dat"
OUTPUT_FILE="${DAT_DIR}out_file.dat"
RATIOS="${DAT_DIR}ratios.dat"
RATIOS_AUX="${DAT_DIR}ratios_aux.dat"
#fPNG="${DAT_DIR}threshold.png"

# borrar el fichero DAT y el fichero PNG
#rm -f $TIMES $MEANS $MEANS2
mkdir -p ${DAT_DIR}

# generar el fichero DAT vacío
#touch $MEANS $TIMES

ALL_IMAGES=""
for ((i=1; i<=NUM_IMG_MAX; i++));do 
	ALL_IMAGES="${ALL_IMAGES} ${IMG_PREFIX}${i}.jpg"
done
ALL_IMAGES="${ALL_IMAGES} ${IMG_PREFIX}6.jpeg"

echo $ALL_IMAGES

if false;then
# Realizar iteraciones con las distintas versiones
echo "Running edge detector versions"

for ((j = 0 ; j < REP ; j += 1));do
    echo "  Iteration $j"
			time=( $(${SERIAL_BAD}  ${ALL_IMAGES} | grep 'Tiempo' | awk '{print $2}') )
      echo -e "edgeDetector ${time[@]}$TAB" >> $TIMES
			time=( $(${SERIAL_GOOD} ${ALL_IMAGES} | grep 'Tiempo' | awk '{print $2}') )
      echo -e "edgeDetector_optLoops ${time[@]}$TAB" >> $TIMES

    #Parallel versions
    for (( Ver=0; Ver<=2; Ver+= 1)); do
				time=( $(${PARALLEL}${Ver} ${ALL_IMAGES} | grep 'Tiempo' | awk '{print $2}') )
        echo -e "edgeDetector_par$Ver ${time[@]}$TAB" >> $TIMES
    done
done

cat $TIMES | tr ' ' \\t > $TIMES2 # if we do not change the '.' for ',' awk does not sum
rm -f $TIMES


echo -e "${COLUMN_NAMES}" > $MEANS
# calculate the means
for N in $(awk '{ print $1 }' $TIMES2 | sort -n | uniq); do
	means=$(grep -w $N $TIMES2 | awk '{ t0 += $2; t1 += $3; t2 += $4; t3 += $5; t4 += $6; t5 += $7  n++ } END { printf "%s\t%s\t%s\t%s\t%s\t%s\n", t0/n, t1/n, t2/n, t3/n, t4/n, t5/n }')
	echo -e "$N${TAB}$means" >> $MEANS
done
fi

T0=( $(grep -w edgeDetector $MEANS | head -1 ) )

rm -f $RATIOS_AUX

sed "1d" $MEANS | while read n t;do
	j=1
	ratios=""
	for s in ${t[@]};do
		ratios="$ratios$(echo "scale=$DECIMALS;${T0[$j]}/$s" | bc)${TAB}"
		j=$(( $j + 1 ))
	done
  echo -e "$n${TAB}${ratios[@]}" >> $RATIOS_AUX
done 

#reordenamiento de lineas
echo -e "${COLUMN_NAMES}" > $RATIOS #column names
grep -w "edgeDetector" $RATIOS_AUX >> $RATIOS
grep -w "edgeDetector_optLoops" $RATIOS_AUX >> $RATIOS
grep "edgeDetector_par" $RATIOS_AUX >> $RATIOS


rm -f ${OUTPUT_FILE}
