#!/bin/bash
#
#$ -S /bin/bash
#$ -q amd.q
#$ -cwd
#$ -o salida.out
#$ -j y

# Anadir valgrind y gnuplot al path
export PATH=$PATH:/share/apps/tools/valgrind/bin:/share/apps/tools/gnuplot/bin

# Indicar ruta librerías valgrind
export VALGRIND_LIB=/share/apps/tools/valgrind/lib/valgrind

# Pasamos el nombre del script como parámetro
echo "Ejecutando script $1..."
echo ""
source $1

# linea 4: la cola a la que se manda la tarea, usar la misma cola para toda la práctica
# lanzamiento de un script "script.sh": qsub scr_launcher.sh script.sh