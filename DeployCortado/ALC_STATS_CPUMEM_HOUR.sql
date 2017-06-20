-- Se llena con datos de las tablas ALC_SYSTEM_CPU_STATS_IPRAN_RAW y ALC_SYSTEM_MEM_STATS_IPRAN_RAW
--
-- DROP TABLE ALC_STATS_CPUMEM_HOUR PURGE;
--
CREATE TABLE ALC_STATS_CPUMEM_HOUR(
  FECHA	                      DATE,
  MONITORED_OBJECT_SITE_ID	  VARCHAR2(50 CHAR),
  MONITORED_OBJECT_SITE_NAME	VARCHAR2(50 CHAR),
  SYSTEM_CPU_USAGE	          NUMBER,
  SYSTEM_CPU_USAGE_AVG	      NUMBER,
  SYSTEM_CPU_USAGE_MAX	      NUMBER,
  SYSTEM_MEMORY_USAGE	        NUMBER,
  SYSTEM_MEMORY_USAGE_AVG_MB	NUMBER,
  SYSTEM_MEMORY_USAGE_MAX_MB	NUMBER,
  SYSTEM_MEMORY_USAGE_AVG_PCT	NUMBER,
  SYSTEM_MEMORY_USAGE_MAX_PCT NUMBER,
  AVAILABLE_MEMORY	          NUMBER,
  AVAILABLE_MEMORY_AVG_MB	    NUMBER,
  AVAILABLE_MEMORY_MAX_MB	    NUMBER,
  AVAILABLE_MEMORY_AVG_PCT	  NUMBER,
  AVAILABLE_MEMORY_MAX_PCT	  NUMBER,
  ALLOCATED_MEMORY	          NUMBER,
  ALLOCATED_MEMORY_MB	        NUMBER
)NOLOGGING NOCOMPRESS
PARTITION BY RANGE (FECHA)
INTERVAL (NUMTODSINTERVAL (1,'HOUR'))
(
PARTITION STATSCPUMEMHOUR_FIRST VALUES LESS THAN (TO_DATE('2017-02-01 00:00:00','SYYYY-MM-DD HH24:MI:SS')) 
)
TABLESPACE TBS_HOUR;

COMMENT ON TABLE ALC_STATS_CPUMEM_HOUR IS 'Se llena con datos de las tablas ALC_SYSTEM_CPU_STATS_IPRAN_RAW y ALC_SYSTEM_MEM_STATS_IPRAN_RAW';

CREATE INDEX IDX_ALC_STATS_CPUMEM_HOUR ON ALC_STATS_CPUMEM_HOUR (FECHA,MONITORED_OBJECT_SITE_ID,MONITORED_OBJECT_SITE_NAME) 
LOCAL TABLESPACE TBS_HOUR;

CREATE INDEX IDX_ALC_STATS_CPUMEM_HOUR_F ON ALC_STATS_CPUMEM_HOUR (TO_CHAR(FECHA,'DD.MM.YYYY')) 
LOCAL TABLESPACE TBS_HOUR;

CREATE INDEX IDX_ALC_STATS_CPUMEM_HOUR_FH ON ALC_STATS_CPUMEM_HOUR (TO_CHAR(FECHA,'DD.MM.YYYY HH24')) 
LOCAL TABLESPACE TBS_HOUR;