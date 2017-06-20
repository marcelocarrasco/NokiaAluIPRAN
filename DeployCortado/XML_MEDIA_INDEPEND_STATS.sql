--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_mediaIndependStats.xml

DROP TABLE XML_MEDIA_INDEPEND_STATS PURGE;

CREATE TABLE XML_MEDIA_INDEPEND_STATS (
    FECHA                         DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-33,2)||'.'||
                                                                          SUBSTR(NOMBRE_CSV,-35,2)||'.'||
                                                                          SUBSTR(NOMBRE_CSV,-39,4)||' '||
                                                                          SUBSTR(NOMBRE_CSV,-31,2)||':'||
                                                                          SUBSTR(NOMBRE_CSV,-29,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
    ,SPECIFIC_TYPE	              VARCHAR2(50 CHAR)
    ,DESCRIPTION	                VARCHAR2(255 CHAR)
    ,MODO	                        VARCHAR2(50 CHAR)
    ,MAC_ADDRESS	                VARCHAR2(50 CHAR)
    ,MTU_VALUE	                  VARCHAR2(50 CHAR)
    ,SPEED	                      VARCHAR2(50 CHAR)
    ,ACTUAL_SPEED	                VARCHAR2(50 CHAR)
    ,NUMBER_OF_POSSIBLE_CHANNELS	NUMBER
    ,SITE_ID	                    VARCHAR2(50 CHAR)
    ,SITE_NAME	                  VARCHAR2(50 CHAR)
    ,OPERATIONAL_STATE	          VARCHAR2(50 CHAR)
    ,ADMINISTRATIVE_STATE	        VARCHAR2(50 CHAR)
    ,OLC_STATE	                  VARCHAR2(255 CHAR)
    ,OBJECT_FULL_NAME	            VARCHAR2(500 CHAR)
    ,MEDICION                     VARCHAR2(50 CHAR)
    ,NOMBRE_CSV                   VARCHAR2(100 CHAR)
) NOCOMPRESS NOLOGGING
TABLESPACE TBS_HOUR;

COMMENT ON TABLE XML_MEDIA_INDEPEND_STATS IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_mediaIndependStats.xml';
COMMENT ON COLUMN XML_MEDIA_INDEPEND_STATS.MODO IS 'Reescritura de la columna MODE por ser palabra reservada';

