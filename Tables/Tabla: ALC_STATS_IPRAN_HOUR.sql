
-- Se llena con datos de ALC_MEDIA_INDP_STATS_IPRAN_RAW
-- DROP TABLE ALC_STATS_IPRAN_HOUR PURGE;

create table ALC_STATS_IPRAN_HOUR(
  FECHA                             DATE    NOT NULL,
  DROP_EVENTS_PERIODIC			        NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  DROPPED_FRAMES_PERIODIC			      NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  RECEIVED_PACKETS_PERIODIC			    NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  TRANSMITTED_PACKETS_PERIODIC		  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  RECEIVED_OCTETS_PERIODIC			    NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  TRANSMITTED_OCTETS_PERIODIC		    NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  RECEIVED_NON_UNI_PACK_PERIODIC	  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats receivedNonUnicastPacketsPeriodic
  TRANS_NON_UNI_PACK_PERIODIC	      NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats transmittedNonUnicastPacketsPeriodic
  RECEIVED_BAD_PACKETS_PERIODIC		  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  TRANS_BAD_PACKETS_PERIODIC        NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats transmittedBadPacketsPeriodic
  INPUT_SPEED				                NUMBER NOT NULL,			-- Viene en el XML	MAX de las cuatro mediciones
  OUTPUT_SPEED				              NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  --DUPLEX					                  VARCHAR2(50 CHAR) NOT NULL,		-- Viene en el XML	equipment.MediaIndependentStats
  --DUPLEX_CHANGES_PERIODIC			      NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  --TIME_CAPTURED				              NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  --PERIODIC_TIME				              NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
  MONITORED_OBJECT_POINTER			    VARCHAR2(500 CHAR) NOT NULL,		-- Viene en el XML	equipment.MediaIndependentStats
  MONITORED_OBJECT_SITEID			      VARCHAR2(50 CHAR) NOT NULL, --(IP)	-- Viene en el XML	equipment.MediaIndependentStats
  MONITORED_OBJECT_SITE_NAME			  VARCHAR2(50 CHAR) NOT NULL, --(EQUIPO)	-- Viene en el XML	equipment.MediaIndependentStats
  IN_BANDWITH_UTIL                  NUMBER NOT NULL,   -- avg(in_Bandwith_Util)	NUMBER		-- Se calcula desde la RAW
  OUT_BANDWITH_UTIL                 NUMBER NOT NULL,   -- avg(out_Bandwith_Util)	NUMBER		-- Se calcula desde la RAW
  REC_OCTETS                        NUMBER NOT NULL,   -- sum(rec_Octets(MB))	NUMBER		-- Se calcula desde la RAW
  TRANS_OCTETS                      NUMBER NOT NULL   -- sum(trans_Octets(MB))	NUMBER		-- Se calcula desde la RAW
) nocompress nologging;
--TABLESPACE TBS_HOUR;

COMMENT ON TABLE ALC_STATS_IPRAN_HOUR IS 'Se llena con datos de ALC_MEDIA_INDP_STATS_IPRAN_RAW';
COMMENT ON COLUMN ALC_STATS_IPRAN_HOUR.RECEIVED_NON_UNI_PACK_PERIODIC IS 'Reescritura de la columna receivedNonUnicastPacketsPeriodic por superar la cantidad de caracteres permitidos para nombrar un objeto';
COMMENT ON COLUMN ALC_STATS_IPRAN_HOUR.TRANS_NON_UNI_PACK_PERIODIC IS 'Reescritura de la columna transmittedNonUnicastPacketsPeriodic por superar la cantidad de caracteres permitidos para nombrar un objeto';
COMMENT ON COLUMN ALC_STATS_IPRAN_HOUR.TRANS_BAD_PACKETS_PERIODIC IS 'Reescritura de la columna transmittedBadPacketsPeriodic por superar la cantidad de caracteres permitidos para nombrar un objeto';

-- Popular
--
INSERT INTO ALC_STATS_IPRAN_HOUR (FECHA
,MONITORED_OBJECT_POINTER
,MONITORED_OBJECT_SITEID
,MONITORED_OBJECT_SITE_NAME
,DROP_EVENTS_PERIODIC
,DROPPED_FRAMES_PERIODIC
,RECEIVED_PACKETS_PERIODIC
,TRANSMITTED_PACKETS_PERIODIC
,RECEIVED_OCTETS_PERIODIC
,TRANSMITTED_OCTETS_PERIODIC
,RECEIVED_NON_UNI_PACK_PERIODIC
,TRANS_NON_UNI_PACK_PERIODIC
,RECEIVED_BAD_PACKETS_PERIODIC
,TRANS_BAD_PACKETS_PERIODIC
,INPUT_SPEED
,OUTPUT_SPEED
,IN_BANDWITH_UTIL
,OUT_BANDWITH_UTIL
,REC_OCTETS
,TRANS_OCTETS)
SELECT  TO_CHAR(FECHA,'DD.MM.YYYY HH24') FECHA
        ,MONITORED_OBJECT_POINTER
        ,MONITORED_OBJECT_SITE_ID
        ,MONITORED_OBJECT_SITENAME
        ,SUM(DROP_EVENTS_PERIODIC)
        ,SUM(DROPPED_FRAMES_PERIODIC)
        ,SUM(RECEIVED_PACKETS_PERIODIC)
        ,SUM(TRANSMITTED_PACKETS_PERIODIC)
        ,SUM(RECEIVED_OCTETS_PERIODIC)
        ,SUM(TRANSMITTED_OCTETS_PERIODIC)
        ,SUM(REC_NON_UNICAST_PAC_PERIODIC)
        ,SUM(TRAN_NON_UNICAST_PAC_PERIODIC)
        ,SUM(RECEIVED_BAD_PACKETS_PERIODIC)
        ,SUM(TRAN_BAD_PACKETS_PERIODIC)
        ,MAX(INPUT_SPEED)
        ,MAX(OUTPUT_SPEED)
        ,ROUND(AVG(IN_BANDWITH_UTIL),3)
        ,ROUND(AVG(OUT_BANDWITH_UTIL),3)
        ,SUM(REC_OCTETS)
        ,SUM(TRANS_OCTETS)    
FROM  ALC_MEDIA_INDP_STATS_IPRAN_RAW
WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '05.12.2016'
AND MONITORED_OBJECT_SITE_ID = '10.2.51.39'
AND MONITORED_OBJECT_SITENAME = 'CF709_JP270_SARF'
--AND MONITORED_OBJECT_POINTER = 'network:10.2.51.39:shelf-1:cardSlot-1:card:daughterCardSlot-1:daughterCard:port-16'
GROUP BY  TO_CHAR(FECHA,'DD.MM.YYYY HH24')
          ,MONITORED_OBJECT_POINTER
          ,MONITORED_OBJECT_SITE_ID
          ,MONITORED_OBJECT_SITENAME;


