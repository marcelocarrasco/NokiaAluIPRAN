#!/bin/bash
<<COMMENT
Popula las tablas XML_* con los datos obtenidos de los *.csv correspondientes

Params: fecha-hora a procesar en formato YYYYMMDDHH ej. 2016112512
COMMENT

#FECHA_PROC=$(date "+%Y%m%d%H")
FECHA_PROC=$1

export ORACLE_HOME=/oracle/app/oracle/product/12.1.0.2/dbhome
export ORACLE_SID=DSMART2
export ORAENV_ASK=NO

echo "------------------------------------------------"
echo "Procesando archivos de la hora == >> $FECHA_PROC"
echo "------------------------------------------------"
#
sh /calidad/Pentaho61/data-integration/kitchen.sh -file=/calidad/NokiaAluIPRAN/PentahoSourceFiles/RunAllJobs.kjb -param:FECHA-PROC=$FECHA_PROC > /calidad/NokiaAluIPRAN/PentahoLogs/testIpranSyncroXML_$FECHA_PROC.log
# sh /calidad/Pentaho61/data-integration/kitchen.sh -file=/calidad/NokiaAluIPRAN/PentahoSourceFiles/PopALC_SYSTEM_CPU_STATS_IPRAN_RAWTable.kjb -param:FECHA-PROC=$FECHA_PROC > /calidad/NokiaAluIPRAN/testIpranSyncroXML.log
# Lipiando el log
sh /calidad/NokiaAluIPRAN/Scripts/cleanupLog.sh '/calidad/NokiaAluIPRAN/testIpranSyncroXML.log'
exit
