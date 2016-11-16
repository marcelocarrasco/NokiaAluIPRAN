
--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_3
-- 
CREATE TABLE XML_SYSTEM_STATS_3(
  SYSTEM_CPU_USAGE	          NUMBER
  ,TIME_CAPTURED	            NUMBER
  ,PERIODIC_TIME	            NUMBER
  ,MONITORED_OBJECT_SITE_ID	  VARCHAR2(15 CHAR)
  ,MONITORED_OBJECT_SITE_NAME	VARCHAR2(50 CHAR)
);
COMMENT ON TABLE XML_SYSTEM_STATS_3 IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_SystemStats.xml_3';
