--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_mediaIndependStats.xml
--
CREATE TABLE XML_MEDIA_INDEPEND_STATS (
    SPECIFIC_TYPE	                VARCHAR2(50 CHAR)
    ,DESCRIPTION	                VARCHAR2(255 CHAR)
    ,MODO	                        VARCHAR2(50 CHAR) --MODE
    ,MAC_ADDRESS	                VARCHAR2(50 CHAR)
    ,MTU_VALUE	                  NUMBER
    ,SPEED	                      NUMBER
    ,ACTUAL_SPEED	                VARCHAR2(50 CHAR)
    ,NUMBER_OF_POSSIBLE_CHANNELS	NUMBER
    ,SITE_ID	                    VARCHAR2(15 CHAR)
    ,SITE_NAME	                  VARCHAR2(50 CHAR)
    ,OPERATIONAL_STATE	          VARCHAR2(50 CHAR)
    ,ADMINISTRATIVE_STATE	        VARCHAR2(50 CHAR)
    ,OLC_STATE	                  VARCHAR2(50 CHAR)
    ,OBJECT_FULL_NAME	            VARCHAR2(500 CHAR)
) NOCOMPRESS NOLOGGING;

COMMENT ON TABLE XML_MEDIA_INDEPEND_STATS IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_mediaIndependStats.xml';
COMMENT ON COLUMN XML_MEDIA_INDEPEND_STATS.MODO IS 'Reescritura de la columna MODE por ser palabra reservada';

