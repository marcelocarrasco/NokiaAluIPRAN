--
-- DROP TABLE ALC_LAGS_IPRAN_SCNEOLR_RAW purge;
--
CREATE TABLE ALC_LAGS_IPRAN_SCNEOLR_RAW (	
  FECHA                         DATE,
	PORT_ID                       VARCHAR2(50 CHAR),
	QUEUE_ID                      NUMBER, 
	LAG_PORT                      VARCHAR2(50 CHAR), 
	TIME_RECORDED                 NUMBER, 
	IN_PROFILE_OCTETS_FORWARDED   NUMBER, 
	IN_PROFILE_OCTETS_DROPPED     NUMBER, 
	OUT_OF_PROFILE_OCTETS_FWDED   NUMBER, 
	OUT_OF_PROFILE_OCTETS_DROPPED NUMBER, 
	MONITORED_OBJECT_SITE_ID      VARCHAR2(50 CHAR), 
	MONITORED_OBJECT_SITE_NAME    VARCHAR2(500 CHAR)
) NOCOMPRESS NOLOGGING
PARTITION BY RANGE (FECHA)
INTERVAL (NUMTODSINTERVAL (1,'HOUR'))
(
PARTITION LAGSIPRANSCNEOLRRAW_FIRST VALUES LESS THAN (TO_DATE('2017-02-01 00:00:00','SYYYY-MM-DD HH24:MI:SS')) 
)
TABLESPACE TBS_HOUR;

COMMENT ON TABLE ALC_LAGS_IPRAN_SCNEOLR_RAW IS 'Tabla RAW para las mediciones serviceCombinedNetworkEgressOctetsLogRecord';

CREATE INDEX IDX_LAGS_IPRAN_SCNEOLR_RAW ON ALC_LAGS_IPRAN_SCNEOLR_RAW(FECHA,MONITORED_OBJECT_SITE_ID,MONITORED_OBJECT_SITE_NAME)
LOCAL TABLESPACE TBS_HOUR;

CREATE INDEX IDX_LAGSIPRANSCNEOLRRAW_F ON ALC_LAGS_IPRAN_SCNEOLR_RAW(TO_CHAR(FECHA,'DD.MM.YYYY'))
LOCAL TABLESPACE TBS_HOUR;

CREATE INDEX IDX_LAGSIPRANSCNEOLRRAW_FH ON ALC_LAGS_IPRAN_SCNEOLR_RAW(TO_CHAR(FECHA,'DD.MM.YYYY HH24'))
LOCAL TABLESPACE TBS_HOUR;

CREATE PUBLIC SYNONYM ALC_LAGS_IPRAN_SCNEOLR_RAW FOR SMART.ALC_LAGS_IPRAN_SCNEOLR_RAW;

--
-- TYPE
--
CREATE OR REPLACE TYPE ALC_L_IPRAN_SCNEOLR_RAW_ROW AS OBJECT(	
  FECHA                         DATE,
	PORT_ID                       VARCHAR2(50 CHAR),
	QUEUE_ID                      NUMBER, 
	LAG_PORT                      VARCHAR2(50 CHAR), 
	TIME_RECORDED                 NUMBER, 
	IN_PROFILE_OCTETS_FORWARDED   NUMBER, 
	IN_PROFILE_OCTETS_DROPPED     NUMBER, 
	OUT_OF_PROFILE_OCTETS_FWDED   NUMBER, 
	OUT_OF_PROFILE_OCTETS_DROPPED NUMBER, 
	MONITORED_OBJECT_SITE_ID      VARCHAR2(50 CHAR), 
	MONITORED_OBJECT_SITE_NAME    VARCHAR2(500 CHAR)
);

CREATE OR REPLACE TYPE ALC_L_IPRAN_SCNEOLR_RAW_TY IS TABLE OF ALC_L_IPRAN_SCNEOLR_RAW_ROW;