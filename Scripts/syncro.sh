#!/bin/bash

<<COMMENT
Script para sincronizar los archivos de IPRAN en el server local. El archivo includes.conf contiene los archivos a sincronizar.
PARAMS:	RUTA --> Directorio raiz del proyecto e.j. '/calidad/NokiaAlcatelIPRAN'
COMMENT
#
# echo $(date)
RUTA=$1

LISTA_OUTPUT=$1/Scripts/listaArc$(date +'%Y%m%d_%H%m%s').lst

> $LISTA_OUTPUT
echo "Copiando archivos origen --> destino"

rsync -avzu --include-from=$RUTA/Scripts/includes.conf nokia@10.84.92.20:/opt/5620sam/server/xml_output/ $RUTA/xml_output/  > $LISTA_OUTPUT
#rsync -avz --include-from=$RUTA/Scripts/includes.conf nokia@10.84.92.20:/opt/5620sam/server/xml_output/ $RUTA/xml_output/ | sed 's/............//' >> $LISTA_OUTPUT
 
# Agrego la ruta completa a los archivos
sed -i "s,^,$RUTA/xml_output/,g" $LISTA_OUTPUT

# Revesa del archivo
tac $LISTA_OUTPUT > $LISTA_OUTPUT.tmp

# Elimino las siguientes lineas
# total size is 252836536  speedup is 38.96
# sent 807 bytes  received 6488446 bytes  1854072.29 bytes/sec
# /Ruta/al/directorio/NokiaAluIPRAN/xml_output/
sed -e '1,3d' < $LISTA_OUTPUT.tmp > $LISTA_OUTPUT

# Elimino la linea --> receiving incremental file list
sed -i '$d' $LISTA_OUTPUT
# Elimino la linea que empieza con --> ./
sed -i '$d' $LISTA_OUTPUT
# Elimino el archivo .tmp
rm $LISTA_OUTPUT.tmp
# Llamada al parser
# si LISTA_OUTPUT no esta vacia
if [[ -s $LISTA_OUTPUT ]] ; then
  # Reemplazo el caracter . en los nodos padres de los xml
  echo "Reemplazando caracter . en nodos de los xml de la lista $LISTA_OUTPUT"
  sh $1/Scripts/replaceDotInNode.sh $1 $LISTA_OUTPUT
  echo "Ejecutando parser para lista de archivos $LISTA_OUTPUT si esta contiene archivos a parsear"
  java -jar $1/Scripts/GetFilesPrueba.jar $LISTA_OUTPUT
else
  echo "No hay archivos a procesar..."
  rm $LISTA_OUTPUT
fi
# Eliminar el archivo .lst parseado
echo "Elimino $LISTA_OUTPUT ya parseada"
# rm $LISTA_OUTPUT
