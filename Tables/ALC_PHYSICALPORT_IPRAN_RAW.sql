--DROP TABLE ALC_PHYSICALPORT_IPRAN_RAW PURGE;

CREATE TABLE ALC_PHYSICALPORT_IPRAN_RAW(
  FECHA	                      DATE,
  SPECIFIC_TYPE	              VARCHAR2(50 CHAR),
  DESCRIPTION	                VARCHAR2(255 CHAR),
  MODO	                      VARCHAR2(50 CHAR),
  MAC_ADDRESS	                VARCHAR2(50 CHAR),
  MTU_VALUE	                  VARCHAR2(50 CHAR),
  SPEED	                      VARCHAR2(50 CHAR),
  ACTUAL_SPEED	              VARCHAR2(50 CHAR),
  NUMBER_OF_POSSIBLE_CHANNELS	NUMBER,
  SITE_ID	                    VARCHAR2(50 CHAR),
  SITE_NAME	                  VARCHAR2(50 CHAR),
  OPERATIONAL_STATE	          VARCHAR2(50 CHAR),
  ADMINISTRATIVE_STATE	      VARCHAR2(50 CHAR),
  OLC_STATE	                  VARCHAR2(255 CHAR),
  OBJECT_FULL_NAME	          VARCHAR2(500 CHAR)
)NOCOMPRESS NOLOGGING
PARTITION BY RANGE (FECHA)
INTERVAL (NUMTODSINTERVAL (1,'DAY'))
(
PARTITION PHYSICALPORTIPRANRAW_FIRST VALUES LESS THAN (TO_DATE('2017-02-20','SYYYY-MM-DD')) 
)
TABLESPACE TBS_HOUR;

COMMENT ON TABLE ALC_PHYSICALPORT_IPRAN_RAW IS 'Tabla para contener las actualizaciones cada 15 min. de los datos XML';

ALTER TABLE ALC_PHYSICALPORT_IPRAN_RAW ADD CONSTRAINT ALC_PHYSICALPORT_IPRAN_RAW_PK PRIMARY KEY (FECHA, SITE_NAME, OBJECT_FULL_NAME) ENABLE;
---
CREATE OR REPLACE TYPE ALC_PHYSICALPORT_IPRAN_RAW_ROW AS OBJECT(
FECHA	                      DATE,
SPECIFIC_TYPE	              VARCHAR2(50 CHAR),
DESCRIPTION	                VARCHAR2(255 CHAR),
MODO	                      VARCHAR2(50 CHAR),
MAC_ADDRESS	                VARCHAR2(50 CHAR),
MTU_VALUE	                  VARCHAR2(50 CHAR),
SPEED	                      VARCHAR2(50 CHAR),
ACTUAL_SPEED	              VARCHAR2(50 CHAR),
NUMBER_OF_POSSIBLE_CHANNELS	NUMBER,
SITE_ID	                    VARCHAR2(50 CHAR),
SITE_NAME	                  VARCHAR2(50 CHAR),
OPERATIONAL_STATE	          VARCHAR2(50 CHAR),
ADMINISTRATIVE_STATE	      VARCHAR2(50 CHAR),
OLC_STATE	                  VARCHAR2(255 CHAR),
OBJECT_FULL_NAME	          VARCHAR2(500 CHAR)
);

CREATE OR REPLACE TYPE ALC_PHYSICALPORT_IPRAN_RAW_TY IS TABLE OF ALC_PHYSICALPORT_IPRAN_RAW_ROW;


--
CREATE OR REPLACE FUNCTION GET_XML_PHYSICALPORT_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_PHYSICALPORT_IPRAN_RAW_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    
    FOR fila IN (SELECT FECHA,
                        SPECIFIC_TYPE,
                        DESCRIPTION,
                        MODO,
                        MAC_ADDRESS,
                        MTU_VALUE,
                        SPEED,
                        ACTUAL_SPEED,
                        NUMBER_OF_POSSIBLE_CHANNELS,
                        SITE_ID,
                        SITE_NAME,
                        OPERATIONAL_STATE,
                        ADMINISTRATIVE_STATE,
                        OLC_STATE,
                        OBJECT_FULL_NAME
                FROM XML_MEDIA_INDEPEND_STATS
                WHERE TO_CHAR(FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
        PIPE ROW (ALC_PHYSICALPORT_IPRAN_RAW_ROW(fila.FECHA,
                                                fila.SPECIFIC_TYPE,
                                                fila.DESCRIPTION,
                                                fila.MODO,
                                                fila.MAC_ADDRESS,
                                                fila.MTU_VALUE,
                                                fila.SPEED,
                                                fila.ACTUAL_SPEED,
                                                fila.NUMBER_OF_POSSIBLE_CHANNELS,
                                                fila.SITE_ID,
                                                fila.SITE_NAME,
                                                fila.OPERATIONAL_STATE,
                                                fila.ADMINISTRATIVE_STATE,
                                                fila.OLC_STATE,
                                                fila.OBJECT_FULL_NAME));
    END LOOP;
    RETURN;
  END GET_XML_PHYSICALPORT_DATA;
--
INSERT INTO ALC_PHYSICALPORT_IPRAN_RAW
SELECT * FROM TABLE(G_ALC_IPRAN.GET_XML_PHYSICALPORT_DATA('23.02.2017 11'));

EXEC g_alc_ipran.INS_ALC_PHYSICALPORT_IPRAN_RAW('2017022311');
EXEC g_alc_ipran.INS_ALC_PHYSICALPORT_IPRAN_OBJ('23022017');
--
CREATE OR REPLACE PROCEDURE INS_ALC_PHYSICALPORT_IPRAN_RAW(P_FECHAHORA IN VARCHAR2) AS
    CURSOR DATOS(FECHA_HORA VARCHAR2) IS
    SELECT  FECHA,
            SPECIFIC_TYPE,
            DESCRIPTION,
            MODO,
            MAC_ADDRESS,
            MTU_VALUE,
            SPEED,
            ACTUAL_SPEED,
            NUMBER_OF_POSSIBLE_CHANNELS,
            SITE_ID,
            SITE_NAME,
            OPERATIONAL_STATE,
            ADMINISTRATIVE_STATE,
            OLC_STATE,
            OBJECT_FULL_NAME
    FROM TABLE(GET_XML_PHYSICALPORT_DATA(FECHA_HORA));
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_PHYSICALPORT_RAW IS TABLE OF ALC_PHYSICALPORT_IPRAN_RAW%ROWTYPE;
    V_ALC_PHYSICALPORT_RAW TY_ALC_PHYSICALPORT_RAW;
    --
    V_FECHAHORA VARCHAR2(13 CHAR) := '';
  BEGIN
    -- Genero el formato de fecha DD.MM.YYYY HH24 en funcion de param. de entrada P_FECHAHORA (YYYYMMDDHH24)
    SELECT  SUBSTR(P_FECHAHORA,7,2)||'.'||
            SUBSTR(P_FECHAHORA,5,2)||'.'||
            SUBSTR(P_FECHAHORA,1,4)||
            ' '||
            SUBSTR(P_FECHAHORA,9,2)
    INTO  V_FECHAHORA
    FROM DUAL;
    --
    OPEN DATOS(V_FECHAHORA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_PHYSICALPORT_RAW LIMIT 100--bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_PHYSICALPORT_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_PHYSICALPORT_IPRAN_RAW VALUES V_ALC_PHYSICALPORT_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_PHYSICALPORT_IPRAN_RAW',L_ERRNO,L_MSG,
                                              ' FECHA => '||V_ALC_PHYSICALPORT_RAW(fila).FECHA||                                                                                                              
                                              ' SPECIFIC_TYPE => '||V_ALC_PHYSICALPORT_RAW(fila).SPECIFIC_TYPE||                                                                                              
                                              ' DESCRIPTION => '||V_ALC_PHYSICALPORT_RAW(fila).DESCRIPTION||                                                                                                  
                                              ' MODO => '||V_ALC_PHYSICALPORT_RAW(fila).MODO||                                                                                                                
                                              ' MAC_ADDRESS => '||V_ALC_PHYSICALPORT_RAW(fila).MAC_ADDRESS||                                                                                                  
                                              ' MTU_VALUE => '||V_ALC_PHYSICALPORT_RAW(fila).MTU_VALUE||                                                                                                      
                                              ' SPEED => '||V_ALC_PHYSICALPORT_RAW(fila).SPEED||                                                                                                              
                                              ' ACTUAL_SPEED => '||V_ALC_PHYSICALPORT_RAW(fila).ACTUAL_SPEED||                                                                                                
                                              ' NUMBER_OF_POSSIBLE_CHANNELS => '||TO_CHAR(V_ALC_PHYSICALPORT_RAW(fila).NUMBER_OF_POSSIBLE_CHANNELS)||                                                         
                                              ' SITE_ID => '||V_ALC_PHYSICALPORT_RAW(fila).SITE_ID||                                                                                                          
                                              ' SITE_NAME => '||V_ALC_PHYSICALPORT_RAW(fila).SITE_NAME||                                                                                                      
                                              ' OPERATIONAL_STATE => '||V_ALC_PHYSICALPORT_RAW(fila).OPERATIONAL_STATE||                                                                                      
                                              ' ADMINISTRATIVE_STATE => '||V_ALC_PHYSICALPORT_RAW(fila).ADMINISTRATIVE_STATE||                                                                                
                                              ' OLC_STATE => '||V_ALC_PHYSICALPORT_RAW(fila).OLC_STATE||                                                                                                      
                                              ' OBJECT_FULL_NAME => '||V_ALC_PHYSICALPORT_RAW(fila).OBJECT_FULL_NAME);
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_PHYSICALPORT_IPRAN_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END INS_ALC_PHYSICALPORT_IPRAN_RAW;
--
MERGE INTO ALC_PHYSICALPORT_IPRAN_OBJ ALC
      USING (WITH DATOS AS  (SELECT  /*+ INLINE */
                                    TO_CHAR(FECHA,'DD.MM.YYYY') VALID_START_DATE
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
                            FROM ALC_PHYSICALPORT_IPRAN_RAW
                            WHERE TO_CHAR(FECHA,'DDMMYYYY') = '22022017')
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

--  
-- DATA FOR TEST 10.2.23.205,AP013_FCP70_SAR8,network:10.2.23.205:shelf-1:cardSlot-1:card:daughterCardSlot-1:daughterCard:port-1
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
                                                                      FROM ALC_PHYSICALPORT_IPRAN_RAW
                                                                      WHERE TO_CHAR(FECHA,'DDMMYYYY') = '22022017'
                                                                      )
                                                                WHERE RN = 1);
