-- JOBS
--
select job_name, to_char(log_date,'DD.MM.YYYY HH24:MI:SS') log_date,status,errors
from USER_SCHEDULER_JOB_RUN_DETAILS
where status != 'SUCCEEDED'
and to_date(to_char(log_date,'DD.MM.YYYY'),'DD.MM.YYYY') between (sysdate -7) and sysdate
and job_name in (select job_name--,job_action,repeat_interval
                from DBA_SCHEDULER_JOBS
                where owner = 'SMART'
                and REGEXP_LIKE (repeat_interval, '^FREQ=HOURLY(*)'))
order by 2 desc;

select job_name--,job_action,repeat_interval
from DBA_SCHEDULER_JOBS
where owner = 'SMART'
and REGEXP_LIKE (repeat_interval, '^FREQ=HOURLY(*)');

-- FREQ=HOURLY;BYDAY=MON,TUE,WED,THU,FRI
--
--
-- PARA VER LAS SESIONES 
 select
   c.owner,
   c.object_name,
   c.object_type,
   b.sid,
   b.serial#,
   b.status,
   b.osuser,
   b.machine
from
   v$locked_object a ,
   v$session b,
   dba_objects c
where
   b.sid = a.session_id
and
   a.object_id = c.object_id;
--   
--   
select a.session_id,a.oracle_username, a.os_user_name, b.owner "OBJECT OWNER", b.object_name,b.object_type,a.locked_mode from 
(select object_id, SESSION_ID, ORACLE_USERNAME, OS_USER_NAME, LOCKED_MODE from v$locked_object) a, 
(select object_id, owner, object_name,object_type from dba_objects) b
where a.object_id=b.object_id;   

select sid,serial#,username,machine,module,sql_id from v$session
where schemaname not in ('SYS','DBSNMP');

SELECT sess.sid, sess.serial#,sess.process, sess.status, sess.username, sess.schemaname, sql.sql_text
FROM  v$session sess, 
      v$sql     sql 
WHERE sql.sql_id(+) = sess.sql_id 
AND sess.type     = 'USER';

select * from v$sql
where sql_id = '40a4uwyy0n94h';

--
-- PARA VER EL UNIX_SPID
--
SELECT 
  p.spid                      unix_spid,
  s.sid                       sid, 
  p.addr,
  s.paddr,
  substr(s.username, 1, 10)   username, 
  substr(s.schemaname, 1, 10) schemaname, 
  s.command                   command,
  substr(s.osuser, 1, 10)     osuser, 
  substr(s.machine, 1, 25)    machine
FROM   v$session s, v$process p
WHERE  s.paddr=p.addr
AND s.schemaname = 'SMART'
ORDER BY p.spid;
--
--
SELECT XIDUSN,OBJECT_ID,SESSION_ID,ORACLE_USERNAME,OS_USER_NAME,PROCESS from v$locked_object;

SELECT d.OBJECT_ID, substr(OBJECT_NAME,1,20), l.SESSION_ID, l.ORACLE_USERNAME, l.LOCKED_MODE
from   v$locked_object l, dba_objects d
where  d.OBJECT_ID=l.OBJECT_ID;

select 
   blocking_session, 
   sid, 
   serial#, 
   wait_class,
   seconds_in_wait
from 
   v$session
where 
   blocking_session is not NULL
order by 
   blocking_session;


SELECT * --spid
FROM   v$process
WHERE NOT EXISTS (SELECT 1
                  FROM v$session
                  WHERE paddr = addr);

SELECT s.sid, s.serial#, p.spid
FROM v$process p, v$session s
WHERE p.addr = s.paddr
AND s.username = 'SMART';                  
------------------------------------------------------
-- ESPACIO OCUPADO
------------------------------------------------------
select owner,segment_name,segment_type,SUM(bytes/1024/1024) MB
from dba_segments
where segment_type='TABLE PARTITION'-- and segment_name LIKE '%_RAW' --IN ('ALC_SYSTEM_CPU_STATS_IPRAN_RAW','ALC_SYSTEM_MEM_STATS_IPRAN_RAW')
--and owner = 'MPELLEGRINI'
GROUP BY owner,segment_name,segment_type
order by 3 desc;

-- Tables + Size MB
select owner, table_name, round((num_rows*avg_row_len)/(1024*1024)) MB 
from all_tables 
where owner not in ('SYS','SYSTEM')  -- Exclude system tables.
and num_rows > 0  -- Ignore empty Tables.
order by MB desc -- Biggest first.
;


--Tables + Rows
select owner, table_name, num_rows
 from all_tables 
where owner not like 'SYS%'  -- Exclude system tables.
and num_rows > 0  -- Ignore empty Tables.
order by num_rows desc -- Biggest first.
;

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

-------------------------------------------------------------------------
select fecha
from CSCO_INTERFACE_HOUR
where to_date(to_char(fecha,'DD.MM.YYYY'),'DD.MM.YYYY') between to_date('01.01.2017','DD.MM.YYYY') 
                                                          and to_date('10.01.2017','DD.MM.YYYY')
group by fecha;

desc user_tab_columns
SET FEEDBACK OFF
SET HEAD OFF

select column_name||','
from user_tab_columns
where table_name = 'CSCO_LINKS'
order by COLUMN_ID;

select ''''||COLUMN_NAME||' => '''||CHR(124)||CHR(124)||'P_LINKS_DATA(indice).'||column_name||CHR(124)||CHR(124)
from user_tab_columns
where table_name = 'CSCO_LINKS'
order by COLUMN_ID;

select column_name||'= CSCO_LINKS_tapi_tab(indice).'||column_name||','
from user_tab_columns
where table_name = 'CSCO_LINKS'
order by COLUMN_ID;

SELECT ASCII('|') FROM DUAL;
 
 
 SELECT ELEMENT_ALIASES,COUNT(*)
FROM CSCO_LINKS 
GROUP BY ELEMENT_ALIASES

select * 
from csco_links cl,
(select element_aliases,count(*)
from csco_links
GROUP by element_aliases
having count(*) > 1) cl2
where cl.element_aliases = cl2.element_aliases;


CREATE TABLE CSCO_LINKS_DUP AS
delete FROM CSCO_LINKS
WHERE ELEMENT_ALIASES IN ('nros01rt09-Ten0-1-0_to_TS1001-PEH-02-Ten0-1-0-2',
'ROS-P-R02_Giga0-0-2-0',
'TME298-PEI-01-Giga2-0-0_to_TME298-PEH-01-Giga0-0-0-0',
'ASU-PE-R01-Ten7-2_to_ASU-PE-R02-Ten7-2',
'nros01rt09-Ten1-1-0_to_TS1001-PEH-01-Ten0-1-0-2',
'CR001-PD-02-Ten0-0-0-0_to_CF223-P-02-Ten0-4-0-6')

-----------------------------------------------------
--WEEK FROM SUNDAY THROUGTH SATURDAY

select TRUNC(sysdate, 'iw')-1 AS SUNDAY,
       TRUNC(sysdate, 'iw') + 6 - 1/86400 AS SATURDAY
from dual;
-- FOR A GIVEN DAY, GET FIRST AND LAST DAY OF THE WEEK THAT BELONGS TO
select TRUNC(TO_DATE('30.01.2017','DD.MM.YYYY'), 'iw')-1 AS SUNDAY,
       TRUNC(TO_DATE('30.01.2017','DD.MM.YYYY'), 'iw') + 6 - 1/86400 AS SATURDAY
from dual;
-- Get week of the year
SELECT to_char(to_date('28.01.2017', 'dd-mm-yyyy'), 'ww') as weeknumber from dual;

-- Get current week
SELECT to_char(TO_DATE('29.01.2017','DD.MM.YYYY'), 'ww') as weeknumber from dual;

/*
Seria mas o menos asi:
Si la fecha esta en current_week, no recalcular IBHW.
Si esta, recalcular la IBHW.

*/
CREATE OR REPLACE FUNCTION F_RECALCULAR_IBHW(P_DATE IN VARCHAR2) RETURN NUMBER IS
  V_CURRENT_WEEK  NUMBER; -- week
  V_DATE_WEEK     NUMBER; -- week that given date belongs to
BEGIN
  SELECT  TO_CHAR(TO_DATE(P_DATE, 'DD.MM.YYYY'), 'ww') AS WEEKNUMBER 
  INTO    V_DATE_WEEK
  FROM    DUAL;
  --
  SELECT  TO_CHAR(SYSDATE, 'ww') AS WEEKNUMBER 
  INTO    V_CURRENT_WEEK
  FROM    DUAL;
  --
  IF V_CURRENT_WEEK != V_DATE_WEEK THEN
    RETURN 1;
  END IF;
  --
  RETURN 0;
END F_RECALCULAR_IBHW;


SELECT F_RECALCULAR_IBHW('07.01.2017') FROM DUAL;
--------------------------------------------------------
--------------------------------------------------------
-- PARTICIONES ---
--------------------------------------------------------
SELECT  PARTITION_NAME,
        HIGH_VALUE
FROM  USER_TAB_PARTITIONS
WHERE TABLE_NAME = 'ALC_STATS_IPRAN_HOUR'
AND INTERVAL = 'YES';
              
              
--ALTER TABLE sales DROP PARTITION FOR(TO_DATE('01-SEP-2007','dd-MON-yyyy'));

--TO_DATE(' 2016-12-30 00:00:00', 'SYYYY-MM-DD HH24:MI:SS', 'NLS_CALENDAR=GREGORIAN')

CREATE OR REPLACE PROCEDURE DROP_INTERVAL_PARTITION_SP(P_TABLA IN VARCHAR2,P_TIMESTAMP IN VARCHAR2)
IS
    CURSOR V_CUR
      IS
        SELECT  PARTITION_NAME,
                HIGH_VALUE
          FROM  USER_TAB_PARTITIONS
          WHERE TABLE_NAME = 'ALC_STATS_IPRAN_HOUR'
          AND INTERVAL = 'YES';
  V_HIGH_VALUE TIMESTAMP;
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMART= ''YYYY-MM-DD HH24:MI:SS''';
   FOR V_REC IN V_CUR LOOP
      EXECUTE IMMEDIATE 'BEGIN :1 := ' || V_REC.HIGH_VALUE || '; END;'
        USING OUT V_HIGH_VALUE;
      IF V_HIGH_VALUE = TO_CHAR(TO_DATE(P_TIMESTAMP,'YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') --TRUNC(SYSDATE,'MM')
        THEN
          DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||P_TABLA||' DROP PARTITION ' || V_REC.PARTITION_NAME || ';');
          --EXECUTE IMMEDIATE 'ALTER TABLE INTERVAL_PART_TEST DROP PARTITION ' || V_REC.PARTITION_NAME;
      END IF;
    END LOOP;
END;


SET SERVEROUTPUT ON

DEFINE P_TABLA = 'ALC_MEDIA_INDP_STATS_IPRAN_RAW'
DEFINE P_TIMESTAMP = '2017-02-19 00:00:00';

DECLARE
CURSOR V_CUR IS
SELECT  PARTITION_NAME,
        HIGH_VALUE
FROM    USER_TAB_PARTITIONS
WHERE   TABLE_NAME = 'ALC_MEDIA_INDP_STATS_IPRAN_RAW'
AND INTERVAL = 'YES';
--
V_HIGH_VALUE TIMESTAMP;
BEGIN
    EXECUTE IMMEDIATE 'ALTER SESSION SET NLS_DATE_FORMART= ''YYYY-MM-DD HH24:MI:SS''';
   FOR V_REC IN V_CUR LOOP
      EXECUTE IMMEDIATE 'BEGIN :1 := ' || V_REC.HIGH_VALUE || '; END;'
        USING OUT V_HIGH_VALUE;
      IF V_HIGH_VALUE = TO_CHAR(TO_DATE('&P_TIMESTAMP','YYYY-MM-DD HH24:MI:SS'),'YYYY-MM-DD HH24:MI:SS') --TRUNC(SYSDATE,'MM')
        THEN
          DBMS_OUTPUT.PUT_LINE('ALTER TABLE '||'&P_TABLA'||' DROP PARTITION ' || V_REC.PARTITION_NAME || ';');
          --EXECUTE IMMEDIATE 'ALTER TABLE INTERVAL_PART_TEST DROP PARTITION ' || V_REC.PARTITION_NAME;
      END IF;
    END LOOP;
END;





EXEC DROP_INTERVAL_PARTITION_SP('ALC_MEDIA_INDP_STATS_IPRAN_RAW','2017-02-19 00:00:00');

--
-- PARA GENERAR LOS DATOS PARA EL LOG
SET HEAD OFF
SET FEEDBACK OFF
SET LINES 160
SET PAGES 5000
set feedback off
SET VERIFY OFF

DEFINE  TIPO = 'V_MMSC_SERVICE_ZTE_DAY(I).'
DEFINE TABLA = 'MMSC_SERVICE_ZTE_DAY'
SELECT  CHR(39)||' '||COLUMN_NAME||' => '||CHR(39)||CHR(124)||CHR(124)||
        CASE 
          WHEN DATA_TYPE = 'NUMBER' THEN 'TO_CHAR(&TIPO'||COLUMN_NAME||')||'
          WHEN DATA_TYPE = 'VARCHAR2' THEN '&TIPO'||COLUMN_NAME||'||'
          ELSE '&TIPO'||COLUMN_NAME||'||'
        END
FROM ALL_TAB_COLUMNS
WHERE OWNER = 'MCARRASCO'
AND TABLE_NAME = '&TABLA'
ORDER BY Column_Id;

--
WITH INNER_ONE  AS (SELECT  /*+ INLINE */
                            MAC_ADDRESS
                            ,SITE_ID
                            ,SITE_NAME
                            ,OBJECT_FULL_NAME
                            ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME 
                                                ORDER BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME) RN
                    FROM ALC_PHYSICALPORT_IPRAN_RAW
                    WHERE TO_CHAR(FECHA,'YYYYMMDDHH24') = '20170223'||12
                    ),
     INNER_TWO AS (SELECT  SITE_ID
                          ,SITE_NAME
                          ,MAC_ADDRESS
                          ,OBJECT_FULL_NAME
                    FROM  INNER_ONE
                    WHERE RN = 1)
SELECT  SITE_ID
        ,SITE_NAME
        ,MAC_ADDRESS
        ,OBJECT_FULL_NAME
FROM  ALC_PHYSICALPORT_IPRAN_OBJ
WHERE VALID_FINISH_DATE > SYSDATE
MINUS
SELECT  SITE_ID
      ,SITE_NAME
      ,MAC_ADDRESS
      ,OBJECT_FULL_NAME
FROM  INNER_TWO;

