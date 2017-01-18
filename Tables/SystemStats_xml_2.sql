--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_2
-- DROP TABLE XML_SYSTEM_STATS_2 PURGE;

CREATE TABLE XML_SYSTEM_STATS_2 (
  FECHA                       DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-28,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-30,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-34,4)||' '||
                                                                      SUBSTR(NOMBRE_CSV,-26,2)||':'||
                                                                      SUBSTR(NOMBRE_CSV,-24,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
  ,ALLOCATED_MEMORY	          NUMBER
  ,TIME_CAPTURED	            NUMBER
  ,PERIODIC_TIME	            NUMBER
  ,MONITORED_OBJECT_SITE_ID	  VARCHAR2(15 CHAR)
  ,MONITORED_OBJECT_SITE_NAME	VARCHAR2(50 CHAR)
  ,MEDICION                   VARCHAR2(50 CHAR)
  ,NOMBRE_CSV                 VARCHAR2(100 CHAR)
--  ,ALLOCATED_MEMORY_MB        AS (ALLOCATED_MEMORY/1048576)
)NOCOMPRESS NOLOGGING
--PARTITION BY RANGE (FECHA)
--(PARTITION SYSTEMSTATS220161128 VALUES LESS THAN (TO_DATE('29.11.2016','DD.MM.YYYY')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80)
 TABLESPACE DEVELOPER;

COMMENT ON TABLE XML_SYSTEM_STATS_2 IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_2';

