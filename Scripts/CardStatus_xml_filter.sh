#!/bin/bash
# ----------------------------------------------------#
# Elimina del archivo las filas que contienen valores #
# no necesarios para cargar en las columnas indicadas #
# ----------------------------------------------------#
# Columna --- Pos
# ---------------
# Modo ------------------> 
# SPECIFIC_TYPE ---------> 
# OPERATIONAL_STATE -----> 9
# ADMINISTRATIVE_STATE --> 1
# OLC_STATE -------------> 
#
for i in $(ls $HOME/NokiaAluIPRAN/xml_output/*_CardStatus_xml.csv)
do
  awk -F";" '!($1 == "undefined" || $9 == "portOutOfService")' $i > $i.tmp
  cat $i.tmp > $i
  rm $i.tmp

done
