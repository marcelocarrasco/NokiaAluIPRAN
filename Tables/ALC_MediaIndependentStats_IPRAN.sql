--
-- DROP TABLE ALC_MEDIA_INDP_STATS_IPRAN_AUX
--
create table ALC_MEDIA_INDP_STATS_IPRAN_AUX(
  DROP_EVENTS_PERIODIC	        NUMBER  DEFAULT 0 NOT NULL,
  DROPPED_FRAMES_PERIODIC	      NUMBER  DEFAULT 0 NOT NULL,
  RECEIVED_PACKETS_PERIODIC	    NUMBER  DEFAULT 0 NOT NULL,
  TRANSMITTED_PACKETS_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  RECEIVED_OCTETS_PERIODIC	    NUMBER  DEFAULT 0 NOT NULL,
  TRANSMITTED_OCTETS_PERIODIC	  NUMBER  DEFAULT 0 NOT NULL,
  REC_NON_UNICAST_PAC_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  TRAN_NON_UNICAST_PAC_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  RECEIVED_BAD_PACKETS_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  TRAN_BAD_PACKETS_PERIODIC	    NUMBER  DEFAULT 0 NOT NULL,
  INPUT_SPEED	                  NUMBER  DEFAULT 0 NOT NULL,
  OUTPUT_SPEED	                NUMBER  DEFAULT 0 NOT NULL,
  DUPLEX	                      VARCHAR2(50 CHAR) NOT NULL,
  DUPLEX_CHANGES_PERIODIC	      NUMBER  DEFAULT 0 NOT NULL,
  TIME_CAPTURED	                NUMBER  DEFAULT 0 NOT NULL,
  PERIODIC_TIME	                NUMBER  DEFAULT 0 NOT NULL,
  MONITORED_OBJECT_POINTER	    VARCHAR2(50 CHAR) NOT NULL,
  MONITORED_OBJECT_SITE_ID	    VARCHAR2(50 CHAR) NOT NULL,
  MONITORED_OBJECT_SITENAME	    VARCHAR2(50 CHAR) NOT NULL,
  IN_BANDWITH_UTIL              AS (DECODE(OUTPUT_SPEED,0,0,8*RECEIVED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000))),
  OUT_BANDWITH_UTIL             AS (DECODE(OUTPUT_SPEED,0,0,8*TRANSMITTED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000))),
  REC_OCTETS                    AS (RECEIVED_OCTETS_PERIODIC/1048576),
  TRANS_OCTETS                  AS (TRANSMITTED_OCTETS_PERIODIC/1048576)
)NOCOMPRESS nologging;

COMMENT ON TABLE ALC_MEDIA_INDP_STATS_IPRAN_AUX IS 'Tabla auxiliar para hacer los calculos en forma automatica';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.REC_NON_UNICAST_PAC_PERIODIC IS 'Reescritura de la columna RECEIVED_NON_UNICAST_PACKETS_PERIODIC';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.TRAN_NON_UNICAST_PAC_PERIODIC IS 'Reescritura de la columna TRANSMITTED_NON_UNICAST_PACKETS_PERIODIC';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.TRAN_BAD_PACKETS_PERIODIC IS 'Reescritura de la columna TRANSMITTED_BAD_PACKETS_PERIODIC';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.MONITORED_OBJECT_SITE_ID IS 'TEXT(IP)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.MONITORED_OBJECT_SITENAME IS 'TEXT(EQUIPO)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.IN_BANDWITH_UTIL IS 'Se debe calcular con la fórmula --> 8*RECEIVED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.OUT_BANDWITH_UTIL IS 'Se debe calcular con la fórmula --> 8*TRANSMITTED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.REC_OCTETS IS 'Se debe calcular con la fórmula --> RECEIVED_OCTETS_PERIODIC/1048576	en (MB)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_AUX.TRANS_OCTETS IS 'Se debe calcular con la fórmula --> TRANSMITTED_OCTETS_PERIODIC/1048576	en (MB)';
--
-- DROP TABLE ALC_MEDIA_INDP_STATS_IPRAN_RAW;
--
CREATE TABLE ALC_MEDIA_INDP_STATS_IPRAN_RAW(
  FECHA                         DATE NOT NULL,
  DROP_EVENTS_PERIODIC	        NUMBER  DEFAULT 0 NOT NULL,
  DROPPED_FRAMES_PERIODIC	      NUMBER  DEFAULT 0 NOT NULL,
  RECEIVED_PACKETS_PERIODIC	    NUMBER  DEFAULT 0 NOT NULL,
  TRANSMITTED_PACKETS_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  RECEIVED_OCTETS_PERIODIC	    NUMBER  DEFAULT 0 NOT NULL,
  TRANSMITTED_OCTETS_PERIODIC	  NUMBER  DEFAULT 0 NOT NULL,
  REC_NON_UNICAST_PAC_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  TRAN_NON_UNICAST_PAC_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  RECEIVED_BAD_PACKETS_PERIODIC	NUMBER  DEFAULT 0 NOT NULL,
  TRAN_BAD_PACKETS_PERIODIC	    NUMBER  DEFAULT 0 NOT NULL,
  INPUT_SPEED	                  NUMBER  DEFAULT 0 NOT NULL,
  OUTPUT_SPEED	                NUMBER  DEFAULT 0 NOT NULL,
  DUPLEX	                      VARCHAR2(50 CHAR) NOT NULL,
  DUPLEX_CHANGESPERIODIC	      NUMBER  DEFAULT 0 NOT NULL,
  TIME_CAPTURED	                NUMBER  DEFAULT 0 NOT NULL,
  PERIODIC_TIME	                NUMBER  DEFAULT 0 NOT NULL,
  MONITORED_OBJECT_POINTER	    VARCHAR2(500 CHAR) NOT NULL,
  MONITORED_OBJECT_SITE_ID	    VARCHAR2(50 CHAR) NOT NULL,
  MONITORED_OBJECT_SITENAME	    VARCHAR2(50 CHAR) NOT NULL,
  IN_BANDWITH_UTIL              NUMBER  DEFAULT 0 NOT NULL,
  OUT_BANDWITH_UTIL             NUMBER  DEFAULT 0 NOT NULL,
  REC_OCTETS                    NUMBER  DEFAULT 0 NOT NULL,
  TRANS_OCTETS                  NUMBER  DEFAULT 0 NOT NULL
)NOCOMPRESS nologging
PARTITION BY RANGE (FECHA)
(
PARTITION MEDIAINDPSTATSIPRANR2016121800 VALUES LESS THAN (TO_DATE('18.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121801 VALUES LESS THAN (TO_DATE('18.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121802 VALUES LESS THAN (TO_DATE('18.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121803 VALUES LESS THAN (TO_DATE('18.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121804 VALUES LESS THAN (TO_DATE('18.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121805 VALUES LESS THAN (TO_DATE('18.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121806 VALUES LESS THAN (TO_DATE('18.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121807 VALUES LESS THAN (TO_DATE('18.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121808 VALUES LESS THAN (TO_DATE('18.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121809 VALUES LESS THAN (TO_DATE('18.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121810 VALUES LESS THAN (TO_DATE('18.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121811 VALUES LESS THAN (TO_DATE('18.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121812 VALUES LESS THAN (TO_DATE('18.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121813 VALUES LESS THAN (TO_DATE('18.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121814 VALUES LESS THAN (TO_DATE('18.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121815 VALUES LESS THAN (TO_DATE('18.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121816 VALUES LESS THAN (TO_DATE('18.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121817 VALUES LESS THAN (TO_DATE('18.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121818 VALUES LESS THAN (TO_DATE('18.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121819 VALUES LESS THAN (TO_DATE('18.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121820 VALUES LESS THAN (TO_DATE('18.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121821 VALUES LESS THAN (TO_DATE('18.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121822 VALUES LESS THAN (TO_DATE('18.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121823 VALUES LESS THAN (TO_DATE('19.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121900 VALUES LESS THAN (TO_DATE('19.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121901 VALUES LESS THAN (TO_DATE('19.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121902 VALUES LESS THAN (TO_DATE('19.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121903 VALUES LESS THAN (TO_DATE('19.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121904 VALUES LESS THAN (TO_DATE('19.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121905 VALUES LESS THAN (TO_DATE('19.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121906 VALUES LESS THAN (TO_DATE('19.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121907 VALUES LESS THAN (TO_DATE('19.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121908 VALUES LESS THAN (TO_DATE('19.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121909 VALUES LESS THAN (TO_DATE('19.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121910 VALUES LESS THAN (TO_DATE('19.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121911 VALUES LESS THAN (TO_DATE('19.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121912 VALUES LESS THAN (TO_DATE('19.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121913 VALUES LESS THAN (TO_DATE('19.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121914 VALUES LESS THAN (TO_DATE('19.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121915 VALUES LESS THAN (TO_DATE('19.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121916 VALUES LESS THAN (TO_DATE('19.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121917 VALUES LESS THAN (TO_DATE('19.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121918 VALUES LESS THAN (TO_DATE('19.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121919 VALUES LESS THAN (TO_DATE('19.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121920 VALUES LESS THAN (TO_DATE('19.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121921 VALUES LESS THAN (TO_DATE('19.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121922 VALUES LESS THAN (TO_DATE('19.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016121923 VALUES LESS THAN (TO_DATE('20.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122000 VALUES LESS THAN (TO_DATE('20.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122001 VALUES LESS THAN (TO_DATE('20.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122002 VALUES LESS THAN (TO_DATE('20.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122003 VALUES LESS THAN (TO_DATE('20.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122004 VALUES LESS THAN (TO_DATE('20.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122005 VALUES LESS THAN (TO_DATE('20.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122006 VALUES LESS THAN (TO_DATE('20.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122007 VALUES LESS THAN (TO_DATE('20.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122008 VALUES LESS THAN (TO_DATE('20.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122009 VALUES LESS THAN (TO_DATE('20.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122010 VALUES LESS THAN (TO_DATE('20.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122011 VALUES LESS THAN (TO_DATE('20.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122012 VALUES LESS THAN (TO_DATE('20.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122013 VALUES LESS THAN (TO_DATE('20.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122014 VALUES LESS THAN (TO_DATE('20.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122015 VALUES LESS THAN (TO_DATE('20.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122016 VALUES LESS THAN (TO_DATE('20.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122017 VALUES LESS THAN (TO_DATE('20.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122018 VALUES LESS THAN (TO_DATE('20.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122019 VALUES LESS THAN (TO_DATE('20.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122020 VALUES LESS THAN (TO_DATE('20.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122021 VALUES LESS THAN (TO_DATE('20.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122022 VALUES LESS THAN (TO_DATE('20.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122023 VALUES LESS THAN (TO_DATE('21.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122100 VALUES LESS THAN (TO_DATE('21.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122101 VALUES LESS THAN (TO_DATE('21.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122102 VALUES LESS THAN (TO_DATE('21.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122103 VALUES LESS THAN (TO_DATE('21.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122104 VALUES LESS THAN (TO_DATE('21.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122105 VALUES LESS THAN (TO_DATE('21.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122106 VALUES LESS THAN (TO_DATE('21.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122107 VALUES LESS THAN (TO_DATE('21.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122108 VALUES LESS THAN (TO_DATE('21.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122109 VALUES LESS THAN (TO_DATE('21.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122110 VALUES LESS THAN (TO_DATE('21.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122111 VALUES LESS THAN (TO_DATE('21.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122112 VALUES LESS THAN (TO_DATE('21.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122113 VALUES LESS THAN (TO_DATE('21.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122114 VALUES LESS THAN (TO_DATE('21.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122115 VALUES LESS THAN (TO_DATE('21.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122116 VALUES LESS THAN (TO_DATE('21.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122117 VALUES LESS THAN (TO_DATE('21.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122118 VALUES LESS THAN (TO_DATE('21.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122119 VALUES LESS THAN (TO_DATE('21.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122120 VALUES LESS THAN (TO_DATE('21.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122121 VALUES LESS THAN (TO_DATE('21.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122122 VALUES LESS THAN (TO_DATE('21.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122123 VALUES LESS THAN (TO_DATE('22.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122200 VALUES LESS THAN (TO_DATE('22.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122201 VALUES LESS THAN (TO_DATE('22.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122202 VALUES LESS THAN (TO_DATE('22.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122203 VALUES LESS THAN (TO_DATE('22.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122204 VALUES LESS THAN (TO_DATE('22.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122205 VALUES LESS THAN (TO_DATE('22.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122206 VALUES LESS THAN (TO_DATE('22.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122207 VALUES LESS THAN (TO_DATE('22.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122208 VALUES LESS THAN (TO_DATE('22.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122209 VALUES LESS THAN (TO_DATE('22.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122210 VALUES LESS THAN (TO_DATE('22.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122211 VALUES LESS THAN (TO_DATE('22.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122212 VALUES LESS THAN (TO_DATE('22.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122213 VALUES LESS THAN (TO_DATE('22.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122214 VALUES LESS THAN (TO_DATE('22.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122215 VALUES LESS THAN (TO_DATE('22.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122216 VALUES LESS THAN (TO_DATE('22.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122217 VALUES LESS THAN (TO_DATE('22.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122218 VALUES LESS THAN (TO_DATE('22.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122219 VALUES LESS THAN (TO_DATE('22.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122220 VALUES LESS THAN (TO_DATE('22.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122221 VALUES LESS THAN (TO_DATE('22.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122222 VALUES LESS THAN (TO_DATE('22.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122223 VALUES LESS THAN (TO_DATE('23.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122300 VALUES LESS THAN (TO_DATE('23.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122301 VALUES LESS THAN (TO_DATE('23.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122302 VALUES LESS THAN (TO_DATE('23.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122303 VALUES LESS THAN (TO_DATE('23.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122304 VALUES LESS THAN (TO_DATE('23.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122305 VALUES LESS THAN (TO_DATE('23.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122306 VALUES LESS THAN (TO_DATE('23.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122307 VALUES LESS THAN (TO_DATE('23.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122308 VALUES LESS THAN (TO_DATE('23.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122309 VALUES LESS THAN (TO_DATE('23.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122310 VALUES LESS THAN (TO_DATE('23.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122311 VALUES LESS THAN (TO_DATE('23.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122312 VALUES LESS THAN (TO_DATE('23.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122313 VALUES LESS THAN (TO_DATE('23.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122314 VALUES LESS THAN (TO_DATE('23.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122315 VALUES LESS THAN (TO_DATE('23.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122316 VALUES LESS THAN (TO_DATE('23.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122317 VALUES LESS THAN (TO_DATE('23.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122318 VALUES LESS THAN (TO_DATE('23.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122319 VALUES LESS THAN (TO_DATE('23.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122320 VALUES LESS THAN (TO_DATE('23.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122321 VALUES LESS THAN (TO_DATE('23.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122322 VALUES LESS THAN (TO_DATE('23.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122323 VALUES LESS THAN (TO_DATE('24.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122400 VALUES LESS THAN (TO_DATE('24.12.2016 01','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122401 VALUES LESS THAN (TO_DATE('24.12.2016 02','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122402 VALUES LESS THAN (TO_DATE('24.12.2016 03','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122403 VALUES LESS THAN (TO_DATE('24.12.2016 04','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122404 VALUES LESS THAN (TO_DATE('24.12.2016 05','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122405 VALUES LESS THAN (TO_DATE('24.12.2016 06','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122406 VALUES LESS THAN (TO_DATE('24.12.2016 07','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122407 VALUES LESS THAN (TO_DATE('24.12.2016 08','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122408 VALUES LESS THAN (TO_DATE('24.12.2016 09','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122409 VALUES LESS THAN (TO_DATE('24.12.2016 10','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122410 VALUES LESS THAN (TO_DATE('24.12.2016 11','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122411 VALUES LESS THAN (TO_DATE('24.12.2016 12','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122412 VALUES LESS THAN (TO_DATE('24.12.2016 13','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122413 VALUES LESS THAN (TO_DATE('24.12.2016 14','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122414 VALUES LESS THAN (TO_DATE('24.12.2016 15','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122415 VALUES LESS THAN (TO_DATE('24.12.2016 16','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122416 VALUES LESS THAN (TO_DATE('24.12.2016 17','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122417 VALUES LESS THAN (TO_DATE('24.12.2016 18','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122418 VALUES LESS THAN (TO_DATE('24.12.2016 19','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122419 VALUES LESS THAN (TO_DATE('24.12.2016 20','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122420 VALUES LESS THAN (TO_DATE('24.12.2016 21','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122421 VALUES LESS THAN (TO_DATE('24.12.2016 22','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122422 VALUES LESS THAN (TO_DATE('24.12.2016 23','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80,
PARTITION MEDIAINDPSTATSIPRANR2016122423 VALUES LESS THAN (TO_DATE('25.12.2016 00','DD.MM.YYYY HH24')) TABLESPACE DEVELOPER PCTFREE 10 PCTUSED 80
);

COMMENT ON TABLE ALC_MEDIA_INDP_STATS_IPRAN_RAW IS 'Medicion:  equipment.MediaIndependentStats';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.REC_NON_UNICAST_PAC_PERIODIC IS 'Reescritura de la columna RECEIVED_NON_UNICAST_PACKETS_PERIODIC';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.TRAN_NON_UNICAST_PAC_PERIODIC IS 'Reescritura de la columna TRANSMITTED_NON_UNICAST_PACKETS_PERIODIC';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.TRAN_BAD_PACKETS_PERIODIC IS 'Reescritura de la columna TRANSMITTED_BAD_PACKETS_PERIODIC';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.MONITORED_OBJECT_SITE_ID IS 'TEXT(IP)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.MONITORED_OBJECT_SITENAME IS 'TEXT(EQUIPO)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.IN_BANDWITH_UTIL IS 'Calculada con la fórmula en tabla auxiliar --> 8*RECEIVED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.OUT_BANDWITH_UTIL IS 'Calculada con la fórmula en tabla auxiliar --> 8*TRANSMITTED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.REC_OCTETS IS 'Calculada con la fórmula en tabla auxiliar --> RECEIVED_OCTETS_PERIODIC/1048576	en (MB)';
COMMENT ON COLUMN ALC_MEDIA_INDP_STATS_IPRAN_RAW.TRANS_OCTETS IS 'Calculada con la fórmula en tabla auxiliar --> TRANSMITTED_OCTETS_PERIODIC/1048576	en (MB)';
--
-- Populate RAW
--
--TYPE
create or replace TYPE ALC_M_I_S_IPRAN_RAW_ROW AS OBJECT (
FECHA	DATE,
DROP_EVENTS_PERIODIC	NUMBER,
DROPPED_FRAMES_PERIODIC	NUMBER,
RECEIVED_PACKETS_PERIODIC	NUMBER,
TRANSMITTED_PACKETS_PERIODIC	NUMBER,
RECEIVED_OCTETS_PERIODIC	NUMBER,
TRANSMITTED_OCTETS_PERIODIC	NUMBER,
REC_NON_UNICAST_PAC_PERIODIC	NUMBER,
TRAN_NON_UNICAST_PAC_PERIODIC	NUMBER,
RECEIVED_BAD_PACKETS_PERIODIC	NUMBER,
TRAN_BAD_PACKETS_PERIODIC	NUMBER,
INPUT_SPEED	NUMBER,
OUTPUT_SPEED	NUMBER,
DUPLEX	VARCHAR2(50 CHAR),
DUPLEX_CHANGESPERIODIC	NUMBER,
TIME_CAPTURED	NUMBER,
PERIODIC_TIME	NUMBER,
MONITORED_OBJECT_POINTER	VARCHAR2(500 CHAR),
MONITORED_OBJECT_SITE_ID	VARCHAR2(50 CHAR),
MONITORED_OBJECT_SITENAME	VARCHAR2(50 CHAR),
IN_BANDWITH_UTIL	NUMBER,
OUT_BANDWITH_UTIL	NUMBER,
REC_OCTETS	NUMBER,
TRANS_OCTETS	NUMBER
);
--
create or replace TYPE ALC_M_I_S_IPRAN_RAW_TY IS TABLE OF ALC_M_I_S_IPRAN_RAW_ROW;


--
insert into ALC_MEDIA_INDP_STATS_IPRAN_RAW (FECHA,
  DROP_EVENTS_PERIODIC	        ,
  DROPPED_FRAMES_PERIODIC	      ,
  RECEIVED_PACKETS_PERIODIC	    ,
  TRANSMITTED_PACKETS_PERIODIC	,
  RECEIVED_OCTETS_PERIODIC	    ,
  TRANSMITTED_OCTETS_PERIODIC	  ,
  REC_NON_UNICAST_PAC_PERIODIC	,
  TRAN_NON_UNICAST_PAC_PERIODIC	,
  RECEIVED_BAD_PACKETS_PERIODIC	,
  TRAN_BAD_PACKETS_PERIODIC	    ,
  INPUT_SPEED	                  ,
  OUTPUT_SPEED	                ,
  DUPLEX	                      ,
  DUPLEX_CHANGESPERIODIC	      ,
  TIME_CAPTURED	                ,
  PERIODIC_TIME	                ,
  MONITORED_OBJECT_POINTER	    ,
  MONITORED_OBJECT_SITE_ID	    ,
  MONITORED_OBJECT_SITENAME	    ,
  IN_BANDWITH_UTIL              ,
  OUT_BANDWITH_UTIL             ,
  REC_OCTETS                    ,
  TRANS_OCTETS )
select 
  FECHA                         ,
  DROP_EVENTS_PERIODIC	        ,
  DROPPED_FRAMES_PERIODIC	      ,
  RECEIVED_PACKETS_PERIODIC	    ,
  TRANSMITTED_PACKETS_PERIODIC	,
  RECEIVED_OCTETS_PERIODIC	    ,
  TRANSMITTED_OCTETS_PERIODIC	  ,
  REC_NON_UNICAST_PAC_PERIODIC	,
  TRAN_NON_UNICAST_PAC_PERIODIC	,
  RECEIVED_BAD_PACKETS_PERIODIC	,
  TRAN_BAD_PACKETS_PERIODIC	    ,
  INPUT_SPEED	                  ,
  OUTPUT_SPEED	                ,
  DUPLEX	                      ,
  DUPLEX_CHANGES_PERIODIC	      ,
  TIME_CAPTURED	                ,
  PERIODIC_TIME	                ,
  MONITORED_OBJECT_POINTER	    ,
  MONITORED_OBJECT_SITE_ID	    ,
  MONITORED_OBJECT_SITENAME	    ,
  ROUND(DECODE(OUTPUT_SPEED,0,0,8*RECEIVED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)),2) IN_BANDWITH_UTIL,
  ROUND(DECODE(OUTPUT_SPEED,0,0,8*TRANSMITTED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)),2) OUT_BANDWITH_UTIL,
  ROUND(RECEIVED_OCTETS_PERIODIC/1048576,2) REC_OCTETS,
  ROUND(TRANSMITTED_OCTETS_PERIODIC/1048576,2) TRANS_OCTETS
  
from XML_MEDIA_INDEPEND_STATS_1;



