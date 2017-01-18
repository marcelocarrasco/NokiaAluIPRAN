--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml
-- DROP TABLE XML_SYSTEM_STATS;

CREATE TABLE XML_SYSTEM_STATS (
  FECHA                       DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-26,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-28,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-32,4)||' '||
                                                                      SUBSTR(NOMBRE_CSV,-24,2)||':'||
                                                                      SUBSTR(NOMBRE_CSV,-22,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
  ,SYSTEM_MEMORY_USAGE        NUMBER
  ,TIME_CAPTURED	            NUMBER
  ,PERIODIC_TIME	            NUMBER
  ,MONITORED_OBJECT_SITE_ID	  VARCHAR2(15 CHAR)
  ,MONITORED_OBJECT_SITE_NAME VARCHAR2(50 CHAR)
  ,MEDICION                   VARCHAR2(50 CHAR)
  ,NOMBRE_CSV                 VARCHAR2(100 CHAR)
--  ,SYSTEM_MEMORY_USAGE_MB     AS  (SYSTEM_MEMORY_USAGE/1048576)
--  ,SYSTEM_MEMORY_USAGE_PCT    AS  (DECODE((AVAILABLE_MEMORY+ALLOCATED_MEMORY),0,0,(SYSTEM_MEMORY_USAGE/(AVAILABLE_MEMORY+ALLOCATED_MEMORY))))
  --(SYSTEM_MEMORY_USAGE/(AVAILABLE_MEMORY+ALLOCATED_MEMORY))
)NOCOMPRESS NOLOGGING
--PARTITION BY RANGE (FECHA)
--(PARTITION SYSTEMSTATS20161128 VALUES LESS THAN (TO_DATE('29.11.2016','DD.MM.YYYY')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80)
 TABLESPACE DEVELOPER;


COMMENT ON TABLE XML_SYSTEM_STATS IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml';

