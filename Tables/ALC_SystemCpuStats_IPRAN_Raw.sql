select length('ALC_SYSTEM_CPU_STATS_IPRAN_RAW') from dual;

-- DROP TABLE ALC_SYSTEM_CPU_STATS_IPRAN_RAW;

CREATE TABLE ALC_SYSTEM_CPU_STATS_IPRAN_RAW(
  SYSTEM_CPU_USAGE	          NUMBER  DEFAULT 0 NOT NULL,
  TIME_CAPTURED	              NUMBER  DEFAULT 0 NOT NULL,
  PERIODIC_TIME	              NUMBER  DEFAULT 0 NOT NULL,
  MONITORED_OBJECT_SITE_ID    VARCHAR2(50 CHAR) NOT NULL,
  MONITORED_OBJECT_SITE_NAME  VARCHAR2(50 CHAR) NOT NULL
) NOCOMPRESS NOLOGGING;

COMMENT ON TABLE ALC_SYSTEM_CPU_STATS_IPRAN_RAW IS 'Medición: Medicion de la CPU';