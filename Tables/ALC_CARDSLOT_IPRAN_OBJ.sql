

--
-- 
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
  VALID_FINISH_DATE	      DATE DEFAULT '31.12.2999'
) NOCOMPRESS NOLOGGING;
--TABLESPACE TBS_AUXILIAR;
ALTER TABLE ALC_CARDSLOT_IPRAN_OBJ ADD CONSTRAINT ALC_CARDSLOT_IPRAN_OBJ_PK PRIMARY KEY (SITE_NAME, OBJECT_FULL_NAME, VALID_FINISH_DATE);

MERGE INTO ALC_CARDSLOT_IPRAN_OBJ ALC
USING (WITH DATOS AS  (SELECT  /*+ INLINE */
                              TO_CHAR(FECHA,'DD.MM.YYYY') VALID_START_DATE
                              ,SITE_NAME
                              ,EQUIPMENT_CATEGORY
                              ,EQUIPMENT_STATE
                              ,OPERATIONAL_STATE
                              ,ADMINISTRATIVE_STATE
                              ,IS_EQUIPPED
                              ,HARDWARE_FAILURE_REASON
                              ,IS_EQUIPMENT_INSERTED
                              ,OBJECT_FULL_NAME
                              ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,OBJECT_FULL_NAME 
                                                  ORDER BY SITE_NAME,OBJECT_FULL_NAME) RN
                      FROM XML_CARD_STATUS
                      WHERE TO_CHAR(FECHA,'YYYYMMDD') = '20161205')
      SELECT VALID_START_DATE
            ,SITE_NAME
            ,EQUIPMENT_CATEGORY
            ,EQUIPMENT_STATE
            ,OPERATIONAL_STATE
            ,ADMINISTRATIVE_STATE
            ,IS_EQUIPPED
            ,HARDWARE_FAILURE_REASON
            ,IS_EQUIPMENT_INSERTED
            ,OBJECT_FULL_NAME
      FROM  DATOS
      WHERE RN = 1) TEMP
ON (ALC.SITE_NAME = TEMP.SITE_NAME AND ALC.OBJECT_FULL_NAME = TEMP.OBJECT_FULL_NAME AND ALC.VALID_FINISH_DATE > SYSDATE)
WHEN NOT MATCHED THEN
  INSERT (VALID_START_DATE,SITE_NAME,EQUIPMENT_CATEGORY,EQUIPMENT_STATE,OPERATIONAL_STATE,ADMINISTRATIVE_STATE
         ,IS_EQUIPPED,HARDWARE_FAILURE_REASON,IS_EQUIPMENT_INSERTED,OBJECT_FULL_NAME)
  VALUES (TEMP.VALID_START_DATE,TEMP.SITE_NAME,TEMP.EQUIPMENT_CATEGORY,TEMP.EQUIPMENT_STATE,TEMP.OPERATIONAL_STATE,
          TEMP.ADMINISTRATIVE_STATE,TEMP.IS_EQUIPPED,TEMP.HARDWARE_FAILURE_REASON,TEMP.IS_EQUIPMENT_INSERTED,
          TEMP.OBJECT_FULL_NAME);
--
-- Merge B: actualizar los datos que estan en ALC_CARDSLOT_IPRAN_OBJ que no estan en XML_CARD_STATUS,
-- update VALID_FINISH_DATE = sysdate
-- Aproach: buscar todos las tupas SITE_NAME,, OBJECT_FULL_NAME de ALC_CARDSLOT_IPRAN_OBJ que
-- no estan en XML_MEDIA_INDEPEND_STATS y actualizar VALID_FINISH_DATE = sysdate (BAJA)

UPDATE ALC_CARDSLOT_IPRAN_OBJ SET
  VALID_FINISH_DATE = SYSDATE
WHERE (SITE_NAME,OBJECT_FULL_NAME) IN (
                                        SELECT  SITE_NAME
                                                ,OBJECT_FULL_NAME
                                        FROM  ALC_CARDSLOT_IPRAN_OBJ
                                        WHERE VALID_FINISH_DATE > SYSDATE
                                        MINUS
                                        SELECT  SITE_NAME
                                                ,OBJECT_FULL_NAME
                                        FROM  (SELECT  /*+ INLINE */
                                                      SITE_NAME
                                                      ,OBJECT_FULL_NAME
                                                      ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,OBJECT_FULL_NAME 
                                                                          ORDER BY SITE_NAME,OBJECT_FULL_NAME) RN
                                              FROM XML_CARD_STATUS
                                              WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '05.12.2016'
                                              )
                                        WHERE RN = 1);          