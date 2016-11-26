--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml
-- DROP TABLE XML_SYSTEM_STATS;

CREATE TABLE XML_SYSTEM_STATS (
  FECHA                       VARCHAR2(100 CHAR) GENERATED ALWAYS AS (SUBSTR(NOMBRE_CSV,-26,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-28,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-32,4)||' '||
                                                                      SUBSTR(NOMBRE_CSV,-24,2)||':'||
                                                                      SUBSTR(NOMBRE_CSV,-22,2)) VIRTUAL
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
);

COMMENT ON TABLE XML_SYSTEM_STATS IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml';
