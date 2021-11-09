#!/bin/bash
# 
#$ -S /bin/bash
#$ -q amd.q
#$ -cwd
#$ -o salida.out
#$ -j y

# Anadir hwloc al path
export PATH=$PATH:/share/apps/tools/hwloc/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/share/apps/tools/hwloc/lib64/
# Ejecutar lstopo con salida en formato png (genera un fichero con la imagen)
lstopo --output-format png > figure.png

# linea 4: la cola a la que se manda la tarea, usar la misma cola para toda la práctica
# lanzamiento de la tarea: qsub scr0_topolog.sh