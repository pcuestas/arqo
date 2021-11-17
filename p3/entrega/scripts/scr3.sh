#!/bin/bash

# Pablo Cuesta Sierra, Álvaro Zamanillo Sáez
# Script for the exercise 3

# inicializar variables
P=4
Ninicio=$((256+256*P))
Npaso=32
Nfinal=$((256+256*(P+1)))
NMAXiterations=20
fDATaux=out3/mult_aux.dat
fDAT=out3/mult.dat
fPNGTime=out3/mult_time.png
fPNGCache=out3/mult_cache.png

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNGTime $fDATaux

# generar el fichero DAT vacío
mkdir out3
touch $fDAT
touch $fDATaux

echo "Running slow and fast..."


for i in $(seq 1 1 $NMAXiterations); do 
	for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo " iteration $i - N: $N / $Nfinal..."
		
		multTime=$(./multiplication $N | grep 'time' | awk '{print $3}')
		mult_tTime=$(./multiplication_t $N | grep 'time' | awk '{print $3}')

		echo "$N	$multTime	$mult_tTime" >> $fDATaux
	done
done


fileAux=auxfile.dat
rm -f fileAux
valgrind_exec="valgrind --tool=cachegrind --cachegrind-out-file=$fileAux" 

for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
		echo "cache simulation - N: $N / $Nfinal..."
		
	$valgrind_exec ./multiplication $N &> /dev/null
	multTime=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
	rm -f $fileAux

	$valgrind_exec ./multiplication_t $N &> /dev/null
	mult_tTime=$(cg_annotate $fileAux | grep "PROGRAM TOTALS" | awk '{ printf "%s\t%s",$5, $8}' | tr -d ',')
	rm -f $fileAux

	mean=($(grep -w $N $fDATaux | awk '{ slow += $2; fast += $3; n++ } END { printf "%s\t%s", slow/n, fast/n }'))
	
	echo "$N	${mean[0]}	$multTime	${mean[1]}	$mult_tTime" >> $fDAT

done

