#!/bin/bash
# Lista de archivos a procesar
RUTA=$1/xml_output
LISTA_ARCHIVOS=$2
# Descomentar la siguiente linea para produccion
TODAY=$(date  +'%Y%m%d')

> $LISTA_ARCHIVOS.tmp

for arc in $(cat $LISTA_ARCHIVOS) ;
do
  case $arc in
    $RUTA/$TODAY*_mediaIndependStats.xml_1)
      sed -i 's/equipment.MediaIndependentStats/equipmentMediaIndependentStats/g' $arc
      echo "$arc=$1/Scripts/mediaIndependStats_xml_1.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_mediaIndependStats.xml)
      sed -i 's/equipment.PhysicalPort/equipmentPhysicalPort/g' $arc
      echo "$arc=$1/Scripts/mediaIndependStats_xml.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_CardStatus.xml)
      sed -i 's/equipment.CardSlot/equipmentCardSlot/g' $arc
      echo "$arc=$1/Scripts/CardStatus_xml.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_SystemStats.xml)
      sed -i 's/equipment.SystemMemoryStats/equipmentSystemMemoryStats/g' $arc
      echo "$arc=$1/Scripts/SystemStats_xml.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_SystemStats.xml_1)
      sed -i 's/equipment.AvailableMemoryStats/equipmentAvailableMemoryStats/g' $arc
      echo "$arc=$1/Scripts/SystemStats_xml_1.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_SystemStats.xml_2)
      sed -i 's/equipment.AllocatedMemoryStats/equipmentAllocatedMemoryStats/g' $arc
      echo "$arc=$1/Scripts/SystemStats_xml_2.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_SystemStats.xml_3)
      sed -i 's/equipment.SystemCpuStats/equipmentSystemCpuStats/g' $arc
      echo "$arc=$1/Scripts/SystemStats_xml_3.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    #$RUTA/$TODAY*_SystemStats.xml_5)
      #sed -i 's/ / /g' $arc
    #  ;;
    #$RUTA/$TODAY*_SystemStats.xml_6)
      #sed -i 's/ / /g' $arc
    #  ;;
    $RUTA/$TODAY*_NtwQos.xml_1)
      sed -i 's/service.CombinedNetworkIngressOctetsLogRecord/serviceCombinedNetworkIngressOctetsLogRecord/g' $arc
      echo "$arc=$1/Scripts/NtwQos_xml_1.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    $RUTA/$TODAY*_NtwQos.xml)
      sed -i 's/service.CombinedNetworkEgressOctetsLogRecord/serviceCombinedNetworkEgressOctetsLogRecord/g' $arc
      echo "$arc=$1/Scripts/NtwQos_xml.properties" >> $LISTA_ARCHIVOS.tmp
      ;;
    *)
      ;;
  esac
done
# Copio la lst.tmp a la lst original
mv $LISTA_ARCHIVOS.tmp $LISTA_ARCHIVOS
exit 0
