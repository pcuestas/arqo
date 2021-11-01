
#!/bin/bash

# inicializar variables
P=4
Ninicio=$((256+256*P))
Npaso=32
Nfinal=$((256+256*(P+1)))


fDAT=mult.dat
fDAT1=mult1.dat
fAUX=aux.dat

fPNG_time=mult_time.png
fPNG_cache=mult_cache.png

REP=1

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG_time $fPNG_cache
rm -f $fDAT1 $fDAT

# generar el fichero DAT vacío
touch $fDAT
touch $fDAT1


echo "Running mult and transposed..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);

for ((i=0, slowTime=0, fastTime=0; i<REP;i+=1)); do
    echo "Iteration $i / $REP: "
    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
        
        echo "      N: $N / $Nfinal..."
        

        slowTime=$(./multiplication $N | grep 'time' | awk '{print $3}')
        fastTime=$(./transposed_multiplication $N | grep 'time' | awk '{print $3}')

        echo "$N	$slowTime	$fastTime" >> $fDAT
        
    done
done




#Calcular las medias de las ejecuciones y el numero de misses
for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do

    echo "Ejecutando con valgrind $N / $Nfinal"
    rm -f $fAUX
    touch $fAUX

    media_slow=$(grep $N $fDAT | awk  '{ slow += $2; count++ } END { print slow/count}')
    media_fast=$(grep $N $fDAT | awk  '{ slow += $3; count++ } END { print slow/count}')
    
    conf_valgrind="valgrind --tool=cachegrind --cachegrind-out-file=$fAUX"
    
    $conf_valgrind ./multiplication $N 2> /dev/null > /dev/null
    D1mr_slow=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $5}')
    D1mw_slow=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $8}')

    $conf_valgrind ./transposedmultiplication $N 2> /dev/null > /dev/null
    D1mr_fast=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $5}')
    D1mw_fast=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $8}')
    
    echo "$N	$media_slow     $D1mr_slow      $D1mw_slow    $media_fast       $D1mr_fast      $D1mw_fast" >> $fDAT1
done





echo "Generating plot..."
# llamar a gnuplot para generar el gráfico y pasarle directamente por la entrada
# estándar el script que está entre "<< END_GNUPLOT" y "END_GNUPLOT"
gnuplot << END_GNUPLOT
set title "Multiplication-Transposed Multiplication Execution Time"
set ylabel "Execution time (s)"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG_time"
plot "$fDAT1" using 1:2 with lines lw 2 title "mult", \
     "$fDAT1" using 1:5 with lines lw 2 title "trans"
replot
quit
END_GNUPLOT


gnuplot << END_GNUPLOT
set title "Multiplication-Transposed Multiplication Cache"
set ylabel "#Miss"
set xlabel "Matrix Size"
set key right bottom
set grid
set term png
set output "$fPNG_cache"
plot "$fDAT1" using 1:3 with lines lw 2 title "mult D1mr", \
     "$fDAT1" using 1:4 with lines lw 2 title "mult D1mw", \
     "$fDAT1" using 1:6 with lines lw 2 title "tras D1mr", \
     "$fDAT1" using 1:7 with lines lw 2 title "tras D1mw"
replot
quit
END_GNUPLOT


