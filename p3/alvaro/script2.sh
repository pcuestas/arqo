
#!/bin/bash

# inicializar variables
P=4
Ninicio=$((1024+1024*P))
Npaso=256
Nfinal=$((1024+1024*(P+1)))


fAUX=aux.out.dat

echo "Running slow and fast..."


for ((tam=1024;tam<=8192;tam=tam*2));do
    fDAT_tam=cache_${tam}.dat
    touch $fDAT_tam #creamos el archivo donde vamos a volcar los datos
    
    rm -f $fAUX
    touch $fAUX

    conf_valgrind="valgrind --tool=cachegrind --I1=${tam},1,64 --D1=${tam},1,64 --LL=8388608,1,64 --cachegrind-out-file=$fAUX"
    
    echo "Ejecutando con configuración $conf_valgrind"

    for ((N = Ninicio ; N <= Nfinal ; N += Npaso)); do
        echo "         N: $N / $Nfinal"

        $conf_valgrind ./slow $N 2> /dev/null > /dev/null
        D1mr_slow=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $5}')
        D1mw_slow=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $8}')

        $conf_valgrind ./fast $N 2> /dev/null > /dev/null
        D1mr_fast=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $5}')
        D1mw_fast=$(cg_annotate $fAUX | sed -n '18p' | awk '{print $8}')

        echo "$N    $D1mr_slow  $D1mw_slow  $D1mr_fast  $D1mw_fast" >> $fDAT_tam
        
    done
done





