--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_CardStatus.xml VARCHAR2(100 CHAR)

DROP table XML_CARD_STATUS purge;

CREATE TABLE XML_CARD_STATUS (
    MEDICION                  VARCHAR2(50 CHAR)
    ,SITE_NAME	              VARCHAR2(50 CHAR)
    ,EQUIPMENT_CATEGORY	      VARCHAR2(50 CHAR)
    ,EQUIPMENT_STATE	        VARCHAR2(50 CHAR)
    ,OPERATIONAL_STATE	      VARCHAR2(50 CHAR)
    ,ADMINISTRATIVE_STATE	    VARCHAR2(50 CHAR)
    ,IS_EQUIPPED	            VARCHAR2(50 CHAR)
    ,HARDWARE_FAILURE_REASON	VARCHAR2(50 CHAR)
    ,IS_EQUIPMENT_INSERTED	  VARCHAR2(50 CHAR)
    ,OBJECT_FULL_NAME         VARCHAR2(500 CHAR)
    ,NOMBRE_CSV               VARCHAR2(100 CHAR)
    ,FECHA                    DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-25,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-27,2)||'.'||
                                                                      SUBSTR(NOMBRE_CSV,-31,4)||' '||
                                                                      SUBSTR(NOMBRE_CSV,-23,2)||':'||
                                                                      SUBSTR(NOMBRE_CSV,-21,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
) NOCOMPRESS NOLOGGING
TABLESPACE TBS_HOUR;

COMMENT ON TABLE XML_CARD_STATUS IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_CardStatus.xml';


