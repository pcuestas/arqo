#!/bin/bash
#
#$ -S /bin/bash
#$ -q mv.q
#$ -cwd
#$ -o salida.out
#$ -j y
#$ -pe openmp 8

export OMP_NUM_THREADS=$NSLOTS
export OMP_NESTED=TRUE

# Pablo Cuesta Sierra, Álvaro Zamanillo Sáez
# Script to launch the exercses 1, 2, 3 and 4 scripts


# Anadir valgrind y gnuplot al path
export PATH=$PATH:/share/apps/tools/valgrind/bin:/share/apps/tools/gnuplot/bin

# Indicar ruta librerías valgrind
export VALGRIND_LIB=/share/apps/tools/valgrind/lib/valgrind

# Pasamos el nombre del script como parámetro
echo "Ejecutando script $1..."
echo ""
source $1
