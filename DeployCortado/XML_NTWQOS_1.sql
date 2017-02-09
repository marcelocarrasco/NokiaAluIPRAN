--
-- Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_NtwQos.xml_1

DROP TABLE XML_NTWQOS_1 PURGE;

CREATE TABLE XML_NTWQOS_1 (
    FECHA                             DATE GENERATED ALWAYS AS (TO_DATE(SUBSTR(NOMBRE_CSV,-23,2)||'.'||
                                                                              SUBSTR(NOMBRE_CSV,-25,2)||'.'||
                                                                              SUBSTR(NOMBRE_CSV,-29,4)||' '||
                                                                              SUBSTR(NOMBRE_CSV,-21,2)||':'||
                                                                              SUBSTR(NOMBRE_CSV,-19,2),'DD.MM.YYYY HH24:MI')) VIRTUAL
    ,PORT_ID	                        VARCHAR2(50 CHAR)
    ,QUEUE_ID	                        NUMBER
    ,LAG_PORT	                        VARCHAR2(50 CHAR)
    ,TIME_RECORDED	                  NUMBER
    ,IN_PROFILE_OCTETS_FORWARDED	    NUMBER
    ,IN_PROFILE_OCTETS_DROPPED	      NUMBER
    ,OUT_OF_PROFILE_OCTETS_FWDED    	NUMBER
    ,OUT_OF_PROFILE_OCTETS_DROPPED	  NUMBER
    ,MONITORED_OBJECT_SITE_ID	        VARCHAR2(15 CHAR)
    ,MONITORED_OBJECT_SITE_NAME	      VARCHAR2(500 CHAR)
    ,MEDICION                         VARCHAR2(50 CHAR)
    ,NOMBRE_CSV                       VARCHAR2(100 CHAR)
) NOCOMPRESS NOLOGGING
TABLESPACE TBS_HOUR;

COMMENT ON TABLE XML_NTWQOS_1 IS 'Tabla auxiliar para almacenar la info del archivo YYYYMMDDHH24MI_NtwQos.xml_1';
COMMENT ON COLUMN XML_NTWQOS_1.OUT_OF_PROFILE_OCTETS_FWDED IS 'Reescritura de la columna OUT_OF_PROFILE_OCTETS_FORWARDED por superar los 30 char';

