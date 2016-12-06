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
sh /home/oracle/Pentaho61/data-integration/kitchen.sh -file=/home/oracle/NokiaAluIPRAN/PentahoSourceFiles/RunAllJobs.kjb -param:FECHA-PROC=$FECHA_PROC > /home/oracle/NokiaAluIPRAN/testIpranSyncroXML.log
# Lipiando el log
sh /home/oracle/NokiaAluIPRAN/Scripts/cleanupLog.sh '/home/oracle/NokiaAluIPRAN/testIpranSyncroXML.log'
exit
