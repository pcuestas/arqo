#!/bin/bash

# Generate al exercise 5 tables from the scr5.sh output

DIR_DATA="../outputs/out5/final/"
DIR_TABLES="../../mem/tables/"

python3 table_e4.py ${DIR_DATA}O3/ratios.dat > ${DIR_TABLES}table_e5_O3_ratios
python3 table_e4.py ${DIR_DATA}O3/means.dat > ${DIR_TABLES}table_e5_O3_times
python3 fps_e5.py ${DIR_DATA}O3/means.dat > ${DIR_TABLES}table_e5_O3_fps

python3 table_e4.py ${DIR_DATA}normal/ratios.dat > ${DIR_TABLES}table_e5_normal_ratios
python3 table_e4.py ${DIR_DATA}normal/means.dat > ${DIR_TABLES}table_e5_normal_times
python3 fps_e5.py ${DIR_DATA}normal/means.dat > ${DIR_TABLES}table_e5_normal_fps
