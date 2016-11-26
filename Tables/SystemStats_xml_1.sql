--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_1
-- DROP TABLE XML_SYSTEM_STATS_1 PURGE;

CREATE TABLE XML_SYSTEM_STATS_1 (
  FECHA                       VARCHAR2(100 CHAR) GENERATED ALWAYS AS (SUBSTR(NOMBRE_CSV,-28,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-30,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-34,4)||' '||
                                                                      SUBSTR(NOMBRE_CSV,-26,2)||':'||
                                                                      SUBSTR(NOMBRE_CSV,-24,2)) VIRTUAL
  ,AVAILABLE_MEMORY	          NUMBER
  ,TIME_CAPTURED            	NUMBER
  ,PERIODIC_TIME	            NUMBER
  ,MONITORED_OBJECT_SITE_ID	  VARCHAR2(15 CHAR)
  ,MONITORED_OBJECT_SITE_NAME	VARCHAR2(50 CHAR)
  ,MEDICION                   VARCHAR2(50 CHAR)
  ,NOMBRE_CSV                 VARCHAR2(100 CHAR)
--  ,AVAILABLE_MEMORY_PCT       AS (AVAILABLE_MEMORY/(AVAILABLE_MEMORY+ALLOCATED_MEMORY))
--  ,AVAILABLE_MEMORY_MB        AS (AVAILABLE_MEMORY/1048576)
);

COMMENT ON TABLE XML_SYSTEM_STATS_1 IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_1';