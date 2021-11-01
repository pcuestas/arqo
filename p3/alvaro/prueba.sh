
#!/bin/bash

# inicializar variables
P=4
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))

fDAT=slow_fast_time.dat
fDAT1=slow_fast_time1.dat

fPNG=time_slow_fast.png
fAUX=aux.out.dat
REP=3

# borrar el fichero DAT y el fichero PNG
rm -f $fDAT $fPNG
rm -f $fDAT1

# generar el fichero DAT vacío
touch $fDAT
touch $fDAT1


echo "Running slow and fast..."
# bucle para N desde P hasta Q 
#for N in $(seq $Ninicio $Npaso $Nfinal);

for ((tam=1024;tam<=8192;tam=tam*2));do
    touch cache_${tam}.dat #creamos el archivo donde vamos a volcar los datos

    conf_valgrind="valgrind --tool=cachegrind --I1=${tam},1,64 --cachegrind-out-file=$fAUX"
    echo ejecutando con $conf_valgrind ...
    $conf_valgrind ls
    echo "-----------------------------"
    cg_annotate ls_out.dat | head -n 2
done



