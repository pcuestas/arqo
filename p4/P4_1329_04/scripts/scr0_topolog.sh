#!/bin/bash
# 
#$ -S /bin/bash
#$ -q mv.q
#$ -cwd
#$ -o salida.out
#$ -j y

# Pablo Cuesta Sierra, Álvaro Zamanillo Sáez
# Script for the exercise 0

# Anadir hwloc al path
export PATH=$PATH:/share/apps/tools/hwloc/bin/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/share/apps/tools/hwloc/lib64/

#directorio para los outputs
OUT_DIR="out0"
mkdir -p ${OUT_DIR}

# Ejecutar lstopo con salida en formato png (genera un fichero con la imagen)
lstopo --output-format png > ${OUT_DIR}/figure.png

cat /proc/cpuinfo > ${OUT_DIR}/cpuinfo.out
getconf -a | grep -i cache > ${OUT_DIR}/cache.out
