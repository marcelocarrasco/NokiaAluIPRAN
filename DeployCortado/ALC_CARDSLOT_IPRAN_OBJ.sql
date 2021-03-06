

--
-- DROP TABLE ALC_CARDSLOT_IPRAN_OBJ PURGE;
--
CREATE TABLE ALC_CARDSLOT_IPRAN_OBJ (
  SITE_NAME	              VARCHAR2(50 CHAR),
  EQUIPMENT_CATEGORY	    VARCHAR2(50 CHAR),
  EQUIPMENT_STATE	        VARCHAR2(50 CHAR),
  OPERATIONAL_STATE	      VARCHAR2(50 CHAR),
  ADMINISTRATIVE_STATE	  VARCHAR2(50 CHAR),
  IS_EQUIPPED	            VARCHAR2(50 CHAR),
  HARDWARE_FAILURE_REASON	VARCHAR2(50 CHAR),
  IS_EQUIPMENT_INSERTED	  VARCHAR2(50 CHAR),
  OBJECT_FULL_NAME	      VARCHAR2(500 CHAR),
  VALID_START_DATE	      DATE,
  VALID_FINISH_DATE	      DATE DEFAULT '31.12.9999'
) NOCOMPRESS NOLOGGING
TABLESPACE TBS_AUXILIAR;

ALTER TABLE ALC_CARDSLOT_IPRAN_OBJ ADD CONSTRAINT ALC_CARDSLOT_IPRAN_OBJ_PK PRIMARY KEY (SITE_NAME, OBJECT_FULL_NAME, VALID_FINISH_DATE);

CREATE PUBLIC SYNONYM ALC_CARDSLOT_IPRAN_OBJ FOR SMART.ALC_CARDSLOT_IPRAN_OBJ;