#!/bin/bash
# awk -F";" '!($1 ~ "xs" || $1 ~ "yx")' file
for i in $(ls $HOME/NokiaAluIPRAN/xml_output/*.csv)
do
  # Quito todas las ocurrencias de los datos en toremove.txt de los archivos
  echo "$i"
  awk -F";" '!($6 == "undefined" || $6 == "UNDEFINED")' $i > $i.tmp
#  cat $i.tmp > $i
#  rm $i.tmp

done
