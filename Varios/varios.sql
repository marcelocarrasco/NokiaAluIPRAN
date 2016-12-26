
--set verify off
--define fecha='01.12.2016'
--delete from ALC_MEDIA_INDP_STATS_IPRAN_RAW where to_char(fecha,'DD.MM.YYYY') = '&fecha';
--
--delete from XML_MEDIA_INDEPEND_STATS where substr(fecha,1,10) = '&fecha';
--delete from XML_MEDIA_INDEPEND_STATS_1 where substr(fecha,1,10) = '&fecha';
--delete from XML_SYSTEM_STATS where substr(fecha,1,10) = '&fecha';
--delete from XML_SYSTEM_STATS_1 where substr(fecha,1,10) = '&fecha';
--delete from XML_SYSTEM_STATS_2 where substr(fecha,1,10) = '&fecha';
--delete from XML_SYSTEM_STATS_3 where substr(fecha,1,10) = '&fecha';
--delete from XML_NTWQOS where substr(fecha,1,10) = '&fecha';
--delete from XML_NTWQOS_1 where substr(fecha,1,10) = '&fecha';
--delete from XML_CARD_STATUS where substr(fecha,1,10) = '&fecha';

truncate table XML_MEDIA_INDEPEND_STATS;
truncate table XML_MEDIA_INDEPEND_STATS_1;
truncate table XML_SYSTEM_STATS;
truncate table XML_SYSTEM_STATS_1;
truncate table XML_SYSTEM_STATS_2;
truncate table XML_SYSTEM_STATS_3;
truncate table XML_NTWQOS;
truncate table XML_NTWQOS_1;
truncate table XML_CARD_STATUS;

--------------------------------------------------------------------------------
truncate table ALC_STATS_CPUMEM_BH;                                             
truncate table ALC_STATS_CPUMEM_DAY;                                            
truncate table ALC_STATS_CPUMEM_IBHW;                                           
truncate table ALC_STATS_IPRAN_BH;                                              
truncate table ALC_STATS_IPRAN_DAY;                                             
truncate table ALC_STATS_IPRAN_IBHW;                                            
truncate table ALC_CARDSLOT_IPRAN_OBJ;                                          
truncate table ALC_PHYSICALPORT_IPRAN_OBJ;
--------------------------------------------------------------------------------
truncate table ALC_LAGS_IPRAN_SCNEOLR_RAW;
truncate table ALC_LAGS_IPRAN_SCNIOLR_RAW;
truncate table ALC_MEDIA_INDP_STATS_IPRAN_RAW;
truncate table ALC_SYSTEM_CPU_STATS_IPRAN_RAW;                                  
truncate table ALC_SYSTEM_MEM_STATS_IPRAN_RAW;
--------------------------------------------------------------------------------
truncate table ALC_STATS_CPUMEM_HOUR;                                           
truncate table ALC_STATS_IPRAN_HOUR; 
--------------------------------------------------------------------------------
truncate table files;
--------------------------------------------------------------------------------
create public synonym ALC_LAGS_IPRAN_SCNEOLR_RAW for mcarrasco.ALC_LAGS_IPRAN_SCNEOLR_RAW;
create public synonym ALC_LAGS_IPRAN_SCNIOLR_RAW for mcarrasco.ALC_LAGS_IPRAN_SCNIOLR_RAW;
create public synonym ALC_MEDIA_INDP_STATS_IPRAN_RAW for mcarrasco.ALC_MEDIA_INDP_STATS_IPRAN_RAW;
create public synonym ALC_SYSTEM_CPU_STATS_IPRAN_RAW for mcarrasco.ALC_SYSTEM_CPU_STATS_IPRAN_RAW;                             
create public synonym ALC_SYSTEM_MEM_STATS_IPRAN_RAW for mcarrasco.ALC_SYSTEM_MEM_STATS_IPRAN_RAW;

create public synonym ALC_STATS_CPUMEM_HOUR for MCARRASCO.ALC_STATS_CPUMEM_HOUR;
create public synonym ALC_STATS_IPRAN_HOUR for MCARRASCO.ALC_STATS_IPRAN_HOUR;  

create public synonym ALC_STATS_CPUMEM_DAY for MCARRASCO.ALC_STATS_CPUMEM_DAY;  
create public synonym ALC_STATS_IPRAN_DAY for MCARRASCO.ALC_STATS_IPRAN_DAY; 

create public synonym ALC_STATS_CPUMEM_BH for MCARRASCO.ALC_STATS_CPUMEM_BH;    
create public synonym ALC_STATS_IPRAN_BH for MCARRASCO.ALC_STATS_IPRAN_BH; 

create public synonym ALC_STATS_IPRAN_IBHW for MCARRASCO.ALC_STATS_IPRAN_IBHW;  
create public synonym ALC_STATS_CPUMEM_IBHW for MCARRASCO.ALC_STATS_CPUMEM_IBHW;

create public synonym ALC_CARDSLOT_IPRAN_OBJ for MCARRASCO.ALC_CARDSLOT_IPRAN_OBJ;
create public synonym ALC_PHYSICALPORT_IPRAN_OBJ for MCARRASCO.ALC_PHYSICALPORT_IPRAN_OBJ;
--------------------------------------------------------------------------------
grant select on ALC_LAGS_IPRAN_SCNEOLR_RAW to mstuyck;
grant select on ALC_LAGS_IPRAN_SCNIOLR_RAW to mstuyck;
grant select on ALC_MEDIA_INDP_STATS_IPRAN_RAW to mstuyck;
grant select on ALC_SYSTEM_CPU_STATS_IPRAN_RAW to mstuyck;                       
grant select on ALC_SYSTEM_MEM_STATS_IPRAN_RAW to mstuyck;
grant select on ALC_STATS_IPRAN_IBHW to mstuyck;                                
grant select on ALC_STATS_CPUMEM_IBHW to mstuyck; 
grant select on ALC_STATS_CPUMEM_BH to mstuyck;                                 
grant select on ALC_STATS_IPRAN_BH to mstuyck;                                  
grant select on ALC_STATS_CPUMEM_DAY to mstuyck;                                
grant select on ALC_STATS_IPRAN_DAY to mstuyck;
grant select on ALC_STATS_CPUMEM_HOUR to mstuyck;                               
grant select on ALC_STATS_IPRAN_HOUR to mstuyck;  
grant select on ALC_CARDSLOT_IPRAN_OBJ to mstuyck;                               
grant select on ALC_PHYSICALPORT_IPRAN_OBJ to mstuyck;

grant select on ALC_LAGS_IPRAN_SCNEOLR_RAW to frinaldi;
grant select on ALC_LAGS_IPRAN_SCNIOLR_RAW to frinaldi;
grant select on ALC_MEDIA_INDP_STATS_IPRAN_RAW to frinaldi;
grant select on ALC_SYSTEM_CPU_STATS_IPRAN_RAW to frinaldi;                       
grant select on ALC_SYSTEM_MEM_STATS_IPRAN_RAW to frinaldi;
grant select on ALC_STATS_IPRAN_IBHW to frinaldi;                                
grant select on ALC_STATS_CPUMEM_IBHW to frinaldi; 
grant select on ALC_STATS_CPUMEM_BH to frinaldi;                                 
grant select on ALC_STATS_IPRAN_BH to frinaldi;                                  
grant select on ALC_STATS_CPUMEM_DAY to frinaldi;                                
grant select on ALC_STATS_IPRAN_DAY to frinaldi;
grant select on ALC_STATS_CPUMEM_HOUR to frinaldi;                               
grant select on ALC_STATS_IPRAN_HOUR to frinaldi;  
grant select on ALC_CARDSLOT_IPRAN_OBJ to frinaldi;                               
grant select on ALC_PHYSICALPORT_IPRAN_OBJ to frinaldi;
--------------------------------------------------------------------------------

select 'truncate table '||table_name||';'
from user_tables
where table_name like 'ALC_%';

--------------------------------------------------------------------------------

select 'create public synonym '||table_name||' for MCARRASCO.'||table_name||';'
from user_tables
where table_name like 'ALC_%_OBJ';

--------------------------------------------------------------------------------
select 'grant select on '||table_name||' to mstuyck;'
from user_tables
where table_name like 'ALC_%_HOUR';

--------------------------------------------------------------------------------
SELECT  NOMBRE_CSV
FROM (select '201611241622_mediaIndependStats_xml_1.csv' NOMBRE_CSV from dual)
WHERE REGEXP_LIKE(NOMBRE_CSV,'^2016112416(*mediaIndependStats_xml)\.csv$') --
AND NOMBRE_CSV LIKE '%2016112416%'


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
from dual;
--
SELECT  '${SUM-IPRAN-HOUR}'           																			                                            AS  PROCESS_NAME,
        '${PARAM-SUM-IPRAN-HOUR}'||TO_CHAR(TO_DATE(substr('${FECHA_PROC}',7,2)||'.'||
                                                  substr('${FECHA_PROC}',5,2)||'.'||
                                                  substr('${FECHA_PROC}',1,4)||' '||
                                                  substr('${FECHA_PROC}',9,2),'DD.MM.YYYY HH24')+1,'DD.MM.YYYY HH24')		AS  PARAMS,
        TO_CHAR(TO_DATE(SUBSTR('${FECHA_PROC}',1,10),'DD.MM.YYYY')+1,'DD.MM.YYYY')								                      AS	FECHA_TO_RUN,
        'Daily'                         																			                                          AS  TIPO,
        '${GRUPO}'                      																			                                          AS  GRUPO,
        5                               																			                                          AS  STATUS
FROM  DUAL
--
-- drop table process_to_run purge;
create table process_to_run(
process_name  varchar2(500 char) not null primary key,
params        varchar2(500 char),
fecha_to_run  varchar2(13 char) not null,
tipo          varchar2(50 char) not null,
grupo         varchar2(50 char) not null,
status        number(1) default 1 not null,
procesado     date
) nologging nocompress;
alter table process_to_run add constraint chk_process_to_run check (tipo in ('Hourly','Daily','Weekly','Monthly'));

comment on table process_to_run is 'Contiene todos los procesos PENTAHO (.kjb) que se ejecutaran, funciona como una cola';
comment on column process_to_run.fecha_to_run is 'Representa la fecha-hora que se pasara como parametro al Job';
alter table process_to_run add (JOB_NAME  varchar2(500 char) generated always as (substr(PROCESS_NAME,instr(PROCESS_NAME,'/',-1)+1,length(PROCESS_NAME))) virtual);
--
-- UPDATE DE PROCESS_TO_RUN
--
MERGE INTO  PROCESS_TO_RUN PTR
USING (SELECT COUNT(1)          AS TOTAL_ROWS,
              '${PROCESS_NAME}' AS PROCESS_NAME,
              '${FECHA_PROC}'   AS FECHA_TO_RUN
      FROM  ERROR_LOG_NEW
      WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '${FECHA_PROC}'
      AND SQL_CODE != 0
      AND regexp_like(OBJETO,${REGEXP-CLAUSE})) DATOS
ON  (PTR.FECHA_TO_RUN = DATOS.FECHA_TO_RUN AND PTR.PROCESS_NAME = DATOS.PROCESS_NAME)
WHEN MATCHED THEN
  UPDATE SET  PROCESADO = SYSDATE,
              STATUS = DATOS.STATUS
  WHERE PTR.PROCESS_NAME = DATOS.PROCESS_NAME
  AND   PTR.FECHA_TO_RUN = DATOS.FECHA_TO_RUN;
-------------------------------------------------------------------------  

SELECT  TRIM(PROCESS_NAME)  PROCESS_NAME
        ,TRIM(FECHA_TO_RUN) FECHA_TO_RUN
FROM PROCESS_TO_RUN 
WHERE STATUS != 0
AND   PROCESADO IS NULL
AND   FEHCA_TO_RUN = '20.12.2016 13' --${FECHA-PROC} -- DD.MM.YYYY HH24
;