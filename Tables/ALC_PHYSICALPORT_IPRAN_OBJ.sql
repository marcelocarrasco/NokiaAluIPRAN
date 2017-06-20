--
--
--

CREATE TABLE ALC_PHYSICALPORT_IPRAN_OBJ (
  SPECIFIC_TYPE	              VARCHAR2(50 CHAR),
  DESCRIPTION	                VARCHAR2(255 CHAR),
  MODO	                      VARCHAR2(50 CHAR),
  MAC_ADDRESS	                VARCHAR2(50 CHAR),
  MTU_VALUE	                  VARCHAR2(50 CHAR),
  SPEED	                      VARCHAR2(50 CHAR),
  ACTUAL_SPEED	              VARCHAR2(50 CHAR),
  NUMBER_OF_POSSIBLE_CHANNELS NUMBER,
  SITE_ID	                    VARCHAR2(50 CHAR),
  SITE_NAME	                  VARCHAR2(50 CHAR),
  OPERATIONAL_STATE	          VARCHAR2(50 CHAR),
  ADMINISTRATIVE_STATE	      VARCHAR2(50 CHAR),
  OLC_STATE	                  VARCHAR2(255 CHAR),
  OBJECT_FULL_NAME	          VARCHAR2(500 CHAR),
  VALID_START_DATE            DATE  NOT NULL,
  VALID_FINISH_DATE           DATE DEFAULT '31.12.2999'
) NOCOMPRESS NOLOGGING;
--TABLESPACE TBS_AUXILIAR;

COMMENT ON COLUMN XML_MEDIA_INDEPEND_STATS.MODO IS 'Reescritura de la columna MODE por ser palabra reservada';
--
-- Popular
--
INSERT INTO ALC_PHYSICALPORT_IPRAN_OBJ(VALID_START_DATE
      ,SITE_ID
      ,SITE_NAME
      ,MAC_ADDRESS
      ,OBJECT_FULL_NAME
      ,SPECIFIC_TYPE
      ,DESCRIPTION
      ,MODO
      ,MTU_VALUE
      ,SPEED
      ,ACTUAL_SPEED
      ,NUMBER_OF_POSSIBLE_CHANNELS
      ,OPERATIONAL_STATE
      ,ADMINISTRATIVE_STATE
      ,OLC_STATE)
SELECT VALID_START_DATE
      ,SITE_ID
      ,SITE_NAME
      ,MAC_ADDRESS
      ,OBJECT_FULL_NAME
      ,SPECIFIC_TYPE
      ,DESCRIPTION
      ,MODO
      ,MTU_VALUE
      ,SPEED
      ,ACTUAL_SPEED
      ,NUMBER_OF_POSSIBLE_CHANNELS
      ,OPERATIONAL_STATE
      ,ADMINISTRATIVE_STATE
      ,OLC_STATE
      --,'31.12.9999' VALID_FINISH_DATE
FROM (
      SELECT  TO_CHAR(FECHA,'DD.MM.YYYY') VALID_START_DATE
              ,SPECIFIC_TYPE
              ,DESCRIPTION
              ,MODO
              ,MAC_ADDRESS
              ,MTU_VALUE
              ,SPEED
              ,ACTUAL_SPEED
              ,NUMBER_OF_POSSIBLE_CHANNELS
              ,SITE_ID
              ,SITE_NAME
              ,OPERATIONAL_STATE
              ,ADMINISTRATIVE_STATE
              ,OLC_STATE
              ,OBJECT_FULL_NAME
              ,ROW_NUMBER() OVER (PARTITION BY site_name,site_id,mac_address ORDER BY site_name) RN
      FROM XML_MEDIA_INDEPEND_STATS
      WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '05.12.2016'
      AND MAC_ADDRESS != '00-23-3E-EA-58-B7'
      AND SITE_ID != '10.2.21.4'
      AND SITE_NAME != 'CR001_CTE70_SR7'
      AND OBJECT_FULL_NAME != 'network:10.2.21.4:shelf-1:cardSlot-1:card:daughterCardSlot-2:daughterCard:port-1'
      ) DATOS
WHERE DATOS.RN = 1;

--
-- Merge A: los datos de XML_MEDIA_INDP_STATS que no esten en ALC_PHYSICALPORT_IPRAN_OBJ se agregan.....

MERGE INTO ALC_PHYSICALPORT_IPRAN_OBJ ALC
USING (WITH DATOS AS  (SELECT  /*+ INLINE */
                              TO_CHAR(SYSDATE,'DD.MM.YYYY') VALID_START_DATE
                              ,SPECIFIC_TYPE
                              ,DESCRIPTION
                              ,MODO
                              ,MAC_ADDRESS
                              ,MTU_VALUE
                              ,SPEED
                              ,ACTUAL_SPEED
                              ,NUMBER_OF_POSSIBLE_CHANNELS
                              ,SITE_ID
                              ,SITE_NAME
                              ,OPERATIONAL_STATE
                              ,ADMINISTRATIVE_STATE
                              ,OLC_STATE
                              ,OBJECT_FULL_NAME
                              ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME 
                                                  ORDER BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME) RN
                      FROM XML_MEDIA_INDEPEND_STATS
                      WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '05.12.2016')
      SELECT VALID_START_DATE
            ,SITE_ID
            ,SITE_NAME
            ,MAC_ADDRESS
            ,OBJECT_FULL_NAME
            ,SPECIFIC_TYPE
            ,DESCRIPTION
            ,MODO
            ,MTU_VALUE
            ,SPEED
            ,ACTUAL_SPEED
            ,NUMBER_OF_POSSIBLE_CHANNELS
            ,OPERATIONAL_STATE
            ,ADMINISTRATIVE_STATE
            ,OLC_STATE
      FROM  DATOS
      WHERE RN = 1) TEMP
ON (ALC.SITE_NAME = TEMP.SITE_NAME AND ALC.MAC_ADDRESS = TEMP.MAC_ADDRESS AND ALC.SITE_ID = TEMP.SITE_ID AND
    ALC.OBJECT_FULL_NAME = TEMP.OBJECT_FULL_NAME AND ALC.VALID_FINISH_DATE > SYSDATE)
WHEN NOT MATCHED THEN
  INSERT (VALID_START_DATE,SITE_ID,SITE_NAME,MAC_ADDRESS,OBJECT_FULL_NAME,SPECIFIC_TYPE
         ,DESCRIPTION,MODO,MTU_VALUE,SPEED,ACTUAL_SPEED,NUMBER_OF_POSSIBLE_CHANNELS
         ,OPERATIONAL_STATE,ADMINISTRATIVE_STATE,OLC_STATE)
  VALUES (TEMP.VALID_START_DATE,TEMP.SITE_ID,TEMP.SITE_NAME,TEMP.MAC_ADDRESS,TEMP.OBJECT_FULL_NAME,TEMP.SPECIFIC_TYPE
         ,TEMP.DESCRIPTION,TEMP.MODO,TEMP.MTU_VALUE,TEMP.SPEED,TEMP.ACTUAL_SPEED,TEMP.NUMBER_OF_POSSIBLE_CHANNELS
         ,TEMP.OPERATIONAL_STATE,TEMP.ADMINISTRATIVE_STATE,TEMP.OLC_STATE);
         
         
SELECT * FROM ALC_PHYSICALPORT_IPRAN_OBJ ALC
WHERE ALC.SITE_NAME = 'BA162_SAV70_SR7' 
AND ALC.MAC_ADDRESS = '00-D0-F6-F3-16-31'
AND ALC.SITE_ID = '10.2.22.21'
AND ALC.OBJECT_FULL_NAME ='network:10.2.22.21:shelf-1:cardSlot-1:card:daughterCardSlot-2:daughterCard:port-6';
--
-- Merge B: actualizar los datos que estan en ALC_PHYSICALPORT_IPRAN_OBJ que no estan en XML_MEDIA_INDEPEND_STATS,
-- update VALID_FINISH_DATE = sysdate
-- Aproach: buscar todos las tupas SITE_NAME, SITE_ID, MAC_ADDRESS, OBJECT_FULL_NAME de ALC_PHYSICALPORT_IPRAN_OBJ que
-- no estan en XML_MEDIA_INDEPEND_STATS y actualizar VALID_FINISH_DATE = sysdate (BAJA)

UPDATE ALC_PHYSICALPORT_IPRAN_OBJ SET
  VALID_FINISH_DATE = SYSDATE
WHERE (SITE_ID,SITE_NAME,MAC_ADDRESS,OBJECT_FULL_NAME) IN (
                                                          SELECT  SITE_ID
                                                                  ,SITE_NAME
                                                                  ,MAC_ADDRESS
                                                                  ,OBJECT_FULL_NAME
                                                          FROM  ALC_PHYSICALPORT_IPRAN_OBJ
                                                          WHERE VALID_FINISH_DATE > SYSDATE
                                                          MINUS
                                                          SELECT  SITE_ID
                                                                  ,SITE_NAME
                                                                  ,MAC_ADDRESS
                                                                  ,OBJECT_FULL_NAME
                                                          FROM  (SELECT  /*+ INLINE */
                                                                        MAC_ADDRESS
                                                                        ,SITE_ID
                                                                        ,SITE_NAME
                                                                        ,OBJECT_FULL_NAME
                                                                        ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME 
                                                                                            ORDER BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME) RN
                                                                FROM XML_MEDIA_INDEPEND_STATS
                                                                WHERE TO_CHAR(FECHA,'DD.MM.YYYY') = '05.12.2016'
                                                                )
                                                          WHERE RN = 1);
 
--  
--
SELECT  SPECIFIC_TYPE	              ,
        DESCRIPTION	                ,
        MODO	                      ,
        MAC_ADDRESS	                ,
        MTU_VALUE	                  ,
        SPEED	                      ,
        ACTUAL_SPEED	              ,
        NUMBER_OF_POSSIBLE_CHANNELS ,
        SITE_ID	                    ,
        SITE_NAME	                  ,
        OPERATIONAL_STATE	          ,
        ADMINISTRATIVE_STATE	      ,
        OLC_STATE	                  ,
        OBJECT_FULL_NAME            ,
        ROW_NUMBER() OVER (PARTITION BY SITE_NAME ORDER BY SITE_NAME) RN
FROM XML_MEDIA_INDEPEND_STATS
WHERE SUBSTR(FECHA,1,10) = '30.11.2016'
AND MAC_ADDRESS = '00-00-00-00-00-00'
--GROUP BY MAC_ADDRESS