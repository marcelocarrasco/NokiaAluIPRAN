--
-- TYPE
--
CREATE OR REPLACE TYPE ALC_L_IPRAN_SCNIOLR_RAW_ROW AS OBJECT(
  FECHA	                        DATE,
  PORT_ID	                      VARCHAR2(50 CHAR),
  QUEUE_ID	                    NUMBER,
  LAG_PORT	                    VARCHAR2(50 CHAR),
  TIME_RECORDED	                NUMBER,
  IN_PROFILE_OCTETS_FORWARDED	  NUMBER,
  IN_PROFILE_OCTETS_DROPPED	    NUMBER,
  OUT_OF_PROFILE_OCTETS_FWDED	  NUMBER,
  OUT_OF_PROFILE_OCTETS_DROPPED NUMBER,
  MONITORED_OBJECT_SITE_ID	    VARCHAR2(15 CHAR),
  MONITORED_OBJECT_SITE_NAME	  VARCHAR2(500 CHAR)
);

CREATE OR REPLACE TYPE ALC_L_IPRAN_SCNIOLR_RAW_TY IS TABLE OF ALC_L_IPRAN_SCNIOLR_RAW_ROW;


--
-- DROP TABLE ALC_LAGS_IPRAN_SCNIOLR_RAW PURGE;
--
create table ALC_LAGS_IPRAN_SCNIOLR_RAW (
  FECHA	                        DATE,
  PORT_ID	                      VARCHAR2(50 CHAR),
  QUEUE_ID	                    NUMBER,
  LAG_PORT	                    VARCHAR2(50 CHAR),
  TIME_RECORDED	                NUMBER,
  IN_PROFILE_OCTETS_FORWARDED	  NUMBER,
  IN_PROFILE_OCTETS_DROPPED	    NUMBER,
  OUT_OF_PROFILE_OCTETS_FWDED	  NUMBER,
  OUT_OF_PROFILE_OCTETS_DROPPED NUMBER,
  MONITORED_OBJECT_SITE_ID	    VARCHAR2(15 CHAR),
  MONITORED_OBJECT_SITE_NAME	  VARCHAR2(500 CHAR)
) NOCOMPRESS NOLOGGING;
--TABLESPACE TBS_HOUR;

COMMENT ON TABLE ALC_LAGS_IPRAN_SCNIOLR_RAW IS 'Tabla para las mediciones serviceCombinedNetworkIngressOctetsLogRecord de la tabla XML_NTWQOS_1';

insert into ALC_LAGS_IPRAN_SCNIOLR_RAW (FECHA,PORT_ID,QUEUE_ID,LAG_PORT,TIME_RECORDED,IN_PROFILE_OCTETS_FORWARDED,
                                        IN_PROFILE_OCTETS_DROPPED,OUT_OF_PROFILE_OCTETS_FWDED,OUT_OF_PROFILE_OCTETS_DROPPED,
                                        MONITORED_OBJECT_SITE_ID,MONITORED_OBJECT_SITE_NAME)
select FECHA,PORT_ID,QUEUE_ID,LAG_PORT,TIME_RECORDED,IN_PROFILE_OCTETS_FORWARDED,
                                        IN_PROFILE_OCTETS_DROPPED,OUT_OF_PROFILE_OCTETS_FWDED,OUT_OF_PROFILE_OCTETS_DROPPED,
                                        MONITORED_OBJECT_SITE_ID,MONITORED_OBJECT_SITE_NAME
from XML_NTWQOS_1;