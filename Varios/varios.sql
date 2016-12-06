
set verify off
define fecha='01.12.2016'
delete from ALC_MEDIA_INDP_STATS_IPRAN_RAW where to_char(fecha,'DD.MM.YYYY') = '&fecha';

delete from XML_MEDIA_INDEPEND_STATS where substr(fecha,1,10) = '&fecha';
delete from XML_MEDIA_INDEPEND_STATS_1 where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS_1 where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS_2 where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS_3 where substr(fecha,1,10) = '&fecha';
delete from XML_NTWQOS where substr(fecha,1,10) = '&fecha';
delete from XML_NTWQOS_1 where substr(fecha,1,10) = '&fecha';
delete from XML_CARD_STATUS where substr(fecha,1,10) = '&fecha';



truncate table XML_MEDIA_INDEPEND_STATS;
truncate table XML_MEDIA_INDEPEND_STATS_1;
truncate table XML_SYSTEM_STATS;
truncate table XML_SYSTEM_STATS_1;
truncate table XML_SYSTEM_STATS_2;
truncate table XML_SYSTEM_STATS_3;
truncate table XML_NTWQOS;
truncate table XML_NTWQOS_1;
truncate table XML_CARD_STATUS;

truncate table ALC_SYSTEM_MEM_STATS_IPRAN_RAW;                                  
truncate table ALC_SYSTEM_CPU_STATS_IPRAN_RAW;                                  
truncate table ALC_PHYSICALPORT_IPRAN_OBJ;                                      
truncate table ALC_LAGS_IPRAN_SCNIOLR_RAW;                                      
truncate table ALC_LAGS_IPRAN_SCNEOLR_RAW;                                      
truncate table ALC_MEDIA_INDP_STATS_IPRAN_RAW; 


select 'truncate table '||table_name||';'
from user_tables
where table_name like 'ALC_%';

SELECT  NOMBRE_CSV
FROM (select '201611241622_mediaIndependStats_xml_1.csv' NOMBRE_CSV from dual)
WHERE REGEXP_LIKE(NOMBRE_CSV,'^2016112416(*mediaIndependStats_xml)\.csv$') --
--AND NOT REGEXP_LIKE(nombre_csv,'^*(CardStatus_xml_1)\.csv$')
AND NOMBRE_CSV LIKE '%2016112416%'
--AND SUBSTR(NOMBRE_CSV,-31,8) = '${FECHA-PROC}' --Formato YYYYMMDDHH24
--AND STATUS = 5
--AND PROCESADO IS NULL


insert into CALIDAD_PARAMETROS_TABLAS(NOMBRE_TABLA,NOMBRE_TABLESPACE,PARTICION_ESQUEMA,PARTICION_ESQUEMA_MSC_FECHA,
        PARTICION_FORMATO_MSC_FECHA,PARTICION_TIPO_TABLA,ID_TABLA,OBSERVACIONES,DESCRIPCION_TABLA,PARTICION_PERMISO_CREATE,
        PARTICION_PERMISO_DROP)
SELECT  TABLE_NAME                                                    NOMBRE_TABLA
        ,'DEVELOPER'                                                   NOMBRE_TABLESPACE
        ,REPLACE(SUBSTR(TABLE_NAME,INSTR(TABLE_NAME,'_',1)+1),'_','') PARTICION_ESQUEMA
        ,'YYYYMMDDHH24'                                               PARTICION_ESQUEMA_MSC_FECHA
        ,'DD.MM.YYYY HH24'                                            PARTICION_FORMATO_MSC_FECHA
        ,'Hourly'                                                     PARTICION_TIPO_TABLA
        ,REPLACE(TABLE_NAME,'_','')                                   ID_TABLA
        ,'ENABLED'                                                    OBSERVACIONES
        ,NULL                                                         DESCRIPCION_TABLA
        ,'ENABLED'                                                    PARTICION_PERMISO_CREATE
        ,'ENABLED'                                                    PARTICION_PERMISO_DROP
        --,LENGTH(REPLACE(SUBSTR(TABLE_NAME,INSTR(TABLE_NAME,'_',1)+1),'_','')||'2016092700') LON
FROM USER_TABLES
WHERE TABLE_NAME LIKE 'ALC_%_RAW'
ORDER BY ID_TABLA;



                    
SELECT * FROM TABLE(G_ALC_IPRAN.GET_XML_M_I_STATS_1_DATA('01.12.2016 09'));          


select  substr('2016120109',7,2)||'.'||
        substr('2016120109',5,2)||'.'||
        substr('2016120109',1,4)||
        ' '||
        substr('2016120109',9,2)
from dual