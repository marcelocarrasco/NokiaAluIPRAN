
CREATE TABLE ALC_CARDSLOT_IPRAN_RAW(
  FECHA	                  DATE,
  SITE_NAME	              VARCHAR2(50 CHAR),
  EQUIPMENT_CATEGORY	    VARCHAR2(50 CHAR),
  EQUIPMENT_STATE	        VARCHAR2(50 CHAR),
  OPERATIONAL_STATE	      VARCHAR2(50 CHAR),
  ADMINISTRATIVE_STATE	  VARCHAR2(50 CHAR),
  IS_EQUIPPED	            VARCHAR2(50 CHAR),
  HARDWARE_FAILURE_REASON	VARCHAR2(50 CHAR),
  IS_EQUIPMENT_INSERTED	  VARCHAR2(50 CHAR),
  OBJECT_FULL_NAME	      VARCHAR2(500 CHAR)
)NOCOMPRESS NOLOGGING
PARTITION BY RANGE (FECHA)
INTERVAL (NUMTODSINTERVAL (1,'DAY'))
(
PARTITION CARDSLOTIPRANRAW_FIRST VALUES LESS THAN (TO_DATE('2017-02-20','SYYYY-MM-DD')) 
)
TABLESPACE TBS_HOUR;

COMMENT ON TABLE ALC_CARDSLOT_IPRAN_RAW IS 'Tabla para contener las actualizaciones cada 15 min. de los datos XML';

alter table ALC_CARDSLOT_IPRAN_RAW add constraint ALC_CARDSLOT_IPRAN_RAW_PK primary key(FECHA,SITE_NAME,OBJECT_FULL_NAME) 
ENABLE;
--
CREATE OR REPLACE TYPE ALC_CARDSLOT_RAW_ROW AS OBJECT(
  FECHA	                  DATE,
  SITE_NAME	              VARCHAR2(50 CHAR),
  EQUIPMENT_CATEGORY	    VARCHAR2(50 CHAR),
  EQUIPMENT_STATE	        VARCHAR2(50 CHAR),
  OPERATIONAL_STATE	      VARCHAR2(50 CHAR),
  ADMINISTRATIVE_STATE	  VARCHAR2(50 CHAR),
  IS_EQUIPPED	            VARCHAR2(50 CHAR),
  HARDWARE_FAILURE_REASON VARCHAR2(50 CHAR),
  IS_EQUIPMENT_INSERTED	  VARCHAR2(50 CHAR),
  OBJECT_FULL_NAME	      VARCHAR2(500 CHAR)
);

CREATE OR REPLACE TYPE ALC_CARDSLOT_RAW_TY IS TABLE OF ALC_CARDSLOT_RAW_ROW;

-- POP RAW
CREATE OR REPLACE FUNCTION GET_XML_CARDSTATUS_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_CARDSLOT_RAW_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    
    FOR fila IN (SELECT FECHA,
                        SITE_NAME,
                        EQUIPMENT_CATEGORY,
                        EQUIPMENT_STATE,
                        OPERATIONAL_STATE,
                        ADMINISTRATIVE_STATE,
                        IS_EQUIPPED,
                        HARDWARE_FAILURE_REASON,
                        IS_EQUIPMENT_INSERTED,
                        OBJECT_FULL_NAME
                FROM XML_CARD_STATUS
                WHERE TO_CHAR(FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
        PIPE ROW (ALC_CARDSLOT_RAW_ROW(fila.FECHA,
                                      fila.SITE_NAME,
                                      fila.EQUIPMENT_CATEGORY,
                                      fila.EQUIPMENT_STATE,
                                      fila.OPERATIONAL_STATE,
                                      fila.ADMINISTRATIVE_STATE,
                                      fila.IS_EQUIPPED,
                                      fila.HARDWARE_FAILURE_REASON,
                                      fila.IS_EQUIPMENT_INSERTED,
                                      fila.OBJECT_FULL_NAME));
    END LOOP;
    RETURN;
  END GET_XML_CARDSTATUS_DATA;
--

CREATE OR REPLACE  PROCEDURE INS_ALC_CARDSLOT_IPRAN_RAW(P_FECHAHORA IN VARCHAR2) AS
    CURSOR DATOS(FECHA_HORA VARCHAR2) IS
    SELECT  FECHA,
            SITE_NAME,
            EQUIPMENT_CATEGORY,
            EQUIPMENT_STATE,
            OPERATIONAL_STATE,
            ADMINISTRATIVE_STATE,
            IS_EQUIPPED,
            HARDWARE_FAILURE_REASON,
            IS_EQUIPMENT_INSERTED,
            OBJECT_FULL_NAME
    FROM TABLE(GET_XML_CARDSTATUS_DATA(FECHA_HORA));
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_CARDSLOT_RAW IS TABLE OF ALC_CARDSLOT_IPRAN_RAW%ROWTYPE;
    V_ALC_CARDSLOT_RAW TY_ALC_CARDSLOT_RAW;
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
      FETCH DATOS BULK COLLECT INTO V_ALC_CARDSLOT_RAW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_CARDSLOT_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_CARDSLOT_IPRAN_RAW VALUES V_ALC_CARDSLOT_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_CARDSLOT_IPRAN_RAW',L_ERRNO,L_MSG,
                                              ' FECHA => '||V_ALC_CARDSLOT_RAW(L_IDX).FECHA||                                                                                                                
                                              ' SITE_NAME => '||V_ALC_CARDSLOT_RAW(L_IDX).SITE_NAME||                                                                                                        
                                              ' EQUIPMENT_CATEGORY => '||V_ALC_CARDSLOT_RAW(L_IDX).EQUIPMENT_CATEGORY||                                                                                      
                                              ' EQUIPMENT_STATE => '||V_ALC_CARDSLOT_RAW(L_IDX).EQUIPMENT_STATE||                                                                                            
                                              ' OPERATIONAL_STATE => '||V_ALC_CARDSLOT_RAW(L_IDX).OPERATIONAL_STATE||                                                                                        
                                              ' ADMINISTRATIVE_STATE => '||V_ALC_CARDSLOT_RAW(L_IDX).ADMINISTRATIVE_STATE||                                                                                  
                                              ' IS_EQUIPPED => '||V_ALC_CARDSLOT_RAW(L_IDX).IS_EQUIPPED||                                                                                                    
                                              ' HARDWARE_FAILURE_REASON => '||V_ALC_CARDSLOT_RAW(L_IDX).HARDWARE_FAILURE_REASON||                                                                            
                                              ' IS_EQUIPMENT_INSERTED => '||V_ALC_CARDSLOT_RAW(L_IDX).IS_EQUIPMENT_INSERTED||                                                                                
                                              ' OBJECT_FULL_NAME => '||V_ALC_CARDSLOT_RAW(L_IDX).OBJECT_FULL_NAME);
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_CARDSLOT_IPRAN_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END INS_ALC_CARDSLOT_IPRAN_RAW;

--

-- TRUNCATE TABLE ALC_CARDSLOT_IPRAN_RAW;

INSERT INTO ALC_CARDSLOT_IPRAN_RAW
SELECT * FROM TABLE(G_ALC_IPRAN.GET_XML_CARDSTATUS_DATA('23.02.2017 11'));

--
-- POP OBJ
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
                            FROM ALC_CARDSLOT_IPRAN_RAW
                            WHERE TO_CHAR(FECHA,'DDMMYYYY') = '20022017')
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
-- DATOS DE TEST
-- (SITE_NAME,OBJECT_FULL_NAME) --> (CF764_EDM70_SARM,	network:10.2.94.124:shelf-1:cardSlot-1)
--

                
UPDATE ALC_CARDSLOT_IPRAN_OBJ SET
        VALID_FINISH_DATE = SYSDATE
      WHERE (SITE_NAME,OBJECT_FULL_NAME) IN   (
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
                                                    FROM ALC_CARDSLOT_IPRAN_RAW
                                                    WHERE TO_CHAR(FECHA,'DDMMYYYY') = '20022017'
                                                    )
                                              WHERE RN = 1
                                              )
                                            