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

fDAT="${DAT_DIR}pi_.dat"
fDAT2="${DAT_DIR}pi.dat"
fAUX="${DAT_DIR}aux.dat"
fAUX2="${DAT_DIR}aux2.dat"
OUTPUT_FILE="${DAT_DIR}out_file.dat"
RATIOS="${DAT_DIR}ratios.dat"
#fPNG="${DAT_DIR}threshold.png"

# borrar el fichero DAT y el fichero PNG
rm -f $fAUX $fDAT $fDAT2
mkdir -p ${DAT_DIR}

# generar el fichero DAT vacío
touch $fDAT $fAUX

ALL_IMAGES=""
for ((i=1; i<=NUM_IMG_MAX; i++));do 
	ALL_IMAGES="${ALL_IMAGES} ${IMG_PREFIX}${i}.jpg"
done
ALL_IMAGES="${ALL_IMAGES} ${IMG_PREFIX}6.jpeg"

echo $ALL_IMAGES


# Realizar iteraciones con las distintas versiones
echo "Running edge detector versions"

for ((j = 0 ; j < REP ; j += 1));do
    echo "  Iteration $j"
			time=( $(${SERIAL_BAD}  ${ALL_IMAGES} | grep 'Tiempo' | awk '{print $2}') )
      echo -e "edgeDetector ${time[@]}$TAB" >> $fAUX
			time=( $(${SERIAL_GOOD} ${ALL_IMAGES} | grep 'Tiempo' | awk '{print $2}') )
      echo -e "edgeDetector_optLoops ${time[@]}$TAB" >> $fAUX

    #Parallel versions
    for (( Ver=0; Ver<=2; Ver+= 1)); do
				time=( $(${PARALLEL}${Ver} ${ALL_IMAGES} | grep 'Tiempo' | awk '{print $2}') )
        echo -e "edgeDetector_par$Ver ${time[@]}$TAB" >> $fAUX
    done
done

cat $fAUX | tr ' ' \\t | tr '.' ',' > $fAUX2 # if we do not change the '.' for ',' awk does not sum
rm -f $fAUX

# calculate the means
for N in $(awk '{ print $1 }' $fAUX2 | sort -n | uniq); do
	means=$(grep -w $N $fAUX2 | awk '{ t0 += $2; t1 += $3; t2 += $4; t3 += $5; t4 += $6; t5 += $7  n++ } END { printf "%s\t%s\t%s\t%s\t%s\t%s\n", t0/n, t1/n, t2/n, t3/n, t4/n, t5/n }')
	echo -e "$N${TAB}$means" >> $fDAT
done

echo -e "${COLUMN_NAMES}" > $fDAT2
cat $fDAT | tr ',' '.' >> $fDAT2 # if we do not change the ',' for '.' bc does not work
rm -f $fDAT

echo -e "${COLUMN_NAMES}" > $fAUX

T0=( $(grep -w edgeDetector $fDAT2 | head -1 ) )

while read n t;do
	j=$((1))
	ratios=""
	for s in ${t[@]};do 
		ratios="$ratios${TAB}$(echo "scale=$DECIMALS;${T0[$j]}/$s" | bc)"
		j=$(( $j + 1 ))
	done
  echo -e "$n${TAB}${ratios[@]}" >> $fAUX
done < $fDAT2

#reordenamiento de lineas
grep -w "Program" $fAUX > $RATIOS
grep -w "edgeDetector" $fAUX >> $RATIOS
grep -w "edgeDetector_optLoops" $fAUX >> $RATIOS
grep "edgeDetector_par" $fAUX >> $RATIOS


rm -f ${OUTPUT_FILE}
