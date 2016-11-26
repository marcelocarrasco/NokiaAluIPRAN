#!/bin/bash
<<COMMENT
Params: fecha-hora a procesar en formato YYYYMMDDHH ej. 2016112512
COMMENT

FECHA_PROC=$(date "+%Y%m%d%H")

export ORACLE_HOME=/oracle/app/oracle/product/12.1.0.2/dbhome
export ORACLE_SID=DSMART2
export ORAENV_ASK=NO

sh /home/oracle/Pentaho61/data-integration/kitchen.sh -file=/home/oracle/NokiaAluIPRAN/PentahoSourceFiles/RunAllJobs.kjb -param:FECHA-PROC=$FECHA_PROC
exit
