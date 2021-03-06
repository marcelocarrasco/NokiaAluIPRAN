--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_mediaIndependStats.xml_1
--
DROP TABLE XML_MEDIA_INDEPEND_STATS_1 PURGE;

CREATE TABLE XML_MEDIA_INDEPEND_STATS_1 (
  FECHA                           DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-35,2)||'.'||
                                                                          SUBSTR(NOMBRE_CSV,-37,2)||'.'||
                                                                          SUBSTR(NOMBRE_CSV,-41,4)||' '||
                                                                          SUBSTR(NOMBRE_CSV,-33,2)||':'||
                                                                          SUBSTR(NOMBRE_CSV,-31,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
  ,DROP_EVENTS_PERIODIC	          NUMBER
  ,DROPPED_FRAMES_PERIODIC	      NUMBER
  ,RECEIVED_PACKETS_PERIODIC	    NUMBER
  ,TRANSMITTED_PACKETS_PERIODIC	  NUMBER
  ,RECEIVED_OCTETS_PERIODIC       NUMBER
  ,TRANSMITTED_OCTETS_PERIODIC    NUMBER
  ,REC_NON_UNICAST_PAC_PERIODIC   NUMBER
  ,TRAN_NON_UNICAST_PAC_PERIODIC  NUMBER
  ,RECEIVED_BAD_PACKETS_PERIODIC	NUMBER
  ,TRAN_BAD_PACKETS_PERIODIC	    NUMBER
  ,INPUT_SPEED	                  NUMBER
  ,OUTPUT_SPEED	                  NUMBER
  ,DUPLEX	                        VARCHAR2(500 CHAR)
  ,DUPLEX_CHANGES_PERIODIC	      NUMBER
  ,TIME_CAPTURED	                NUMBER
  ,PERIODIC_TIME	                NUMBER
  ,MONITORED_OBJECT_POINTER	      VARCHAR2(500 CHAR)
  ,MONITORED_OBJECT_SITE_ID	      VARCHAR2(15 CHAR)
  ,MONITORED_OBJECT_SITENAME	    VARCHAR2(50 CHAR)
  ,MEDICION                       VARCHAR2(50 CHAR)
  ,NOMBRE_CSV                     VARCHAR2(100 CHAR)
  ) NOCOMPRESS NOLOGGING
TABLESPACE TBS_HOUR;
 
  COMMENT ON TABLE XML_MEDIA_INDEPEND_STATS_1 IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_mediaIndependStats.xml_1';
  COMMENT ON COLUMN XML_MEDIA_INDEPEND_STATS_1.REC_NON_UNICAST_PAC_PERIODIC IS 'Reescritura de la columna RECEIVED_NON_UNICAST_PACKETS_PERIODIC';
  COMMENT ON COLUMN XML_MEDIA_INDEPEND_STATS_1.TRAN_NON_UNICAST_PAC_PERIODIC IS 'Reescritura de la columna TRANSMITTED_NON_UNICAST_PACKETS_PERIODIC';
  COMMENT ON COLUMN XML_MEDIA_INDEPEND_STATS_1.TRAN_BAD_PACKETS_PERIODIC IS 'Reescritura de la columna TRANSMITTED_BAD_PACKETS_PERIODIC';
  
