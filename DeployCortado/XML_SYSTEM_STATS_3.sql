
--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_3

DROP TABLE XML_SYSTEM_STATS_3;

CREATE TABLE XML_SYSTEM_STATS_3(
   FECHA                       DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-28,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-30,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-34,4)||' '||
                                                                      SUBSTR(NOMBRE_CSV,-26,2)||':'||
                                                                      SUBSTR(NOMBRE_CSV,-24,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
  ,SYSTEM_CPU_USAGE	          NUMBER
  ,TIME_CAPTURED	            NUMBER
  ,PERIODIC_TIME	            NUMBER
  ,MONITORED_OBJECT_SITE_ID	  VARCHAR2(15 CHAR)
  ,MONITORED_OBJECT_SITE_NAME	VARCHAR2(50 CHAR)
  ,MEDICION                   VARCHAR2(50 CHAR)
  ,NOMBRE_CSV                 VARCHAR2(100 CHAR)
)NOCOMPRESS NOLOGGING
TABLESPACE TBS_HOUR;
 
COMMENT ON TABLE XML_SYSTEM_STATS_3 IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_3';

