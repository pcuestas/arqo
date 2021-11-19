
#!/bin/bash

# inicializar variables

T=10000000
MAX_STEPS=30

fDAT=threshold.dat
fDAT1=threshold1.dat
fAUX=aux.dat

fPNG_time=mult_time.png
fPNG_cache=mult_cache.png

REP=20

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG_time $fPNG_cache
rm -f $fDAT1 $fDAT

# generar el fichero DAT vacío
touch $fDAT
touch $fDAT1

# delete the directory
rm -f -r out2

# directory for output files
mkdir out2

echo "Running parallel and serial.."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);



i=0
while [ i< MAX_STEPS]; do
    for ((j = 0 ; j <= REP ; j += 1));do
        serieInf=$(./pescalar_serie 0.8*$N | grep 'Tiempo' | awk '{print $2}')
        paralelInf=$(./pescalar_par3 0.8*$N | grep 'time' | awk '{print $2}')
        serieSup=$(./pescalar_serie 1.2*$N | grep 'Tiempo' | awk '{print $2}')
        paralelSup=$(./pescalar_par3 1.2*$N | grep 'time' | awk '{print $2}')
    done

    echo "$N	$serie	$paralel" >> $fDAT 

    i +=1
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

