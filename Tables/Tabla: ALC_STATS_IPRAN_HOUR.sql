
select length('received_Non_Uni_Pack_Periodic') from dual;

create table ALC_STATS_IPRAN_HOUR(
DROP_EVENTS_PERIODIC			        NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
DROPPED_FRAMES_PERIODIC			      NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
RECEIVED_PACKETS_PERIODIC			    NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
TRANSMITTED_PACKETS_PERIODIC		  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
RECEIVED_OCTETS_PERIODIC			    NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
TRANSMITTED_OCTETS_PERIODIC		    NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
RECEIVED_NON_UNI_PACK_PERIODIC	  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats received_Non_Unicast_Packets_Periodic
TRANS_NON_UNI_PACK_PERIODIC	      NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
RECEIVED_BAD_PACKETS_PERIODIC		  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
TRANSMITTED_BAD_PACKETS_PERIODIC  NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
INPUT_SPEED				                NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
OUTPUT_SPEED				              NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
DUPLEX					                  VARCHAR2(50 CHAR) NOT NULL,		-- Viene en el XML	equipment.MediaIndependentStats
DUPLEX_CHANGES_PERIODIC			      NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
TIME_CAPTURED				              NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
PERIODIC_TIME				              NUMBER NOT NULL,			-- Viene en el XML	equipment.MediaIndependentStats
MONITORED_OBJECT_POINTER			    VARCHAR2(50 CHAR) NOT NULL,		-- Viene en el XML	equipment.MediaIndependentStats
MONITORED_OBJECT_SITEID			      VARCHAR2(50 CHAR) NOT NULL, --(IP)	-- Viene en el XML	equipment.MediaIndependentStats
MONITORED_OBJECT_SITE_NAME			  VARCHAR2(50 CHAR) NOT NULL, --(EQUIPO)	-- Viene en el XML	equipment.MediaIndependentStats
in_Bandwith_Util=avg(in_Bandwith_Util)	NUMBER		-- Se calcula desde la RAW
out_Bandwith_Util=avg(out_Bandwith_Util)	NUMBER		-- Se calcula desde la RAW
rec_Octets_MB=sum(rec_Octets(MB))	NUMBER		-- Se calcula desde la RAW
trans_Octets_MB=sum(trans_Octets(MB))	NUMBER		-- Se calcula desde la RAW

) nocompress nologging;
--TABLESPACE TBS_HOUR;