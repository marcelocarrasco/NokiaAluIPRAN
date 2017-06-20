#!/bin/bash
# ----------------------------------------------------#
# Elimina del archivo las filas que contienen valores #
# no necesarios para cargar en las columnas indicadas #
# ----------------------------------------------------#
# Columna --- Pos
# ---------------
# MODO ------------------> 6
# SPECIFIC_TYPE ---------> 14
# OPERATIONAL_STATE -----> 11
# ADMINISTRATIVE_STATE --> 2
# OLC_STATE -------------> 10
#
# 
for i in $(ls $HOME/NokiaAluIPRAN/xml_output/*_mediaIndependStats_xml.csv)
do
  awk -F";" '!($2 == "portOutOfService" || $6 == "undefined" || $10 == "maintenance" || $11 == "portOutOfService" || $14 ~ /port_ds1_e1|port_ipsec_virtual|port_oc3|port_radio/)' $i > $i.tmp
  cat $i.tmp > $i
  rm $i.tmp

done
