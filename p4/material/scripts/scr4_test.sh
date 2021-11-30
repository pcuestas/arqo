
#!/bin/bash

# inicializar variables 


#!/bin/bash

# max function. use: max "number"
max () {
    echo `echo "($1 > $2)*($1) + ($1 < $2)*($2)" | bc`
}

# inicializar variables

REP=15  

DAT_DIR="../outputs/out3/"
SRC_DIR="../src/"

SERIAL="${SRC_DIR}pi_serie"
PARALLEL="${SRC_DIR}pi_par"

fDAT="${DAT_DIR}pi.dat"
fAUX="${DAT_DIR}aux.dat"
#fPNG="${DAT_DIR}threshold.png"


# borrar el fichero DAT y el fichero PNG
rm -f $fAUX $fDAT
mkdir -p ${DAT_DIR}

# generar el fichero DAT vacío
touch $fDAT $fAUX

echo "Running pi_versions"


# Realizar iteraciones con las distintas versiones

for ((j = 0 ; j < REP ; j += 1));do

done
for ((j = 0 ; j < REP ; j += 1));do
    echo "      Iteration $j"

    #Serial version
    program=${SERIAL}
    $program > out_text
    time=$(cat out_text | grep 'Tiempo' | awk '{print $2}')
    res=$(cat out_text | grep 'pi' | awk '{print $3}')
        
    echo "0	$time	$res ">> $fAUX

    #Parallel versions
    for (( Ver=1; Ver<=7; Ver+= 1)); do
        program=${PARALLEL}$Ver
        $program > out_text
        time=$(cat out_text | grep 'Tiempo' | awk '{print $2}')
        res=$(cat out_text | grep 'pi' | awk '{print $3}')
        
        echo "$Ver	$time	$res ">> $fAUX
    done

done

#Calculate means

rm -f out_text
