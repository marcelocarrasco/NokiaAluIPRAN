CREATE OR REPLACE PACKAGE G_ALC_IPRAN AS 
  -- BULK COLLECT LIMIT
  bulk_limit CONSTANT PLS_INTEGER := 100;
   
  -- PIPELINED FUNCTIONS
  FUNCTION GET_XML_M_I_STATS_1_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_M_I_S_IPRAN_RAW_TY PIPELINED;
  FUNCTION GET_XML_SYSTEM_STATS_3_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_S_C_S_IPRAN_TY PIPELINED;
  FUNCTION GET_XML_SYSTEM_STATS_1_2_DATA(P_FECHAHORA  IN VARCHAR2) RETURN ALC_S_M_S_IPRAN_RAW_TY PIPELINED;
  FUNCTION GET_XML_NTWQOS_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_L_IPRAN_SCNEOLR_RAW_TY PIPELINED;
  FUNCTION GET_XML_NTWQOS_1_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_L_IPRAN_SCNIOLR_RAW_TY PIPELINED;
  
  -- PROCEDURES
  /**
  * Inserta los datos de la tabla XML_MEDIA_INDEPEND_STATS_1 en la tabla ALC_MEDIA_INDP_STATS_IPRAN_RAW
  */
  PROCEDURE ALC_M_I_S_IPRAN_RAW_INS(P_FECHAHORA IN VARCHAR2);
  /**
  * Inserta los datos de la tabla XML_SYSTEM_STATS_3 en la tabla ALC_SYTEM_CPU_STATS_IPRAN_RAW
  */
  PROCEDURE ALC_S_C_S_IPRAN_RAW_INS(P_FECHAHORA IN VARCHAR2);
  /**
  * Inserta los datos de laS tabla XML_SYSTEM_STATS, XML_SYSTEM_STATS_1, XML_SYSTEM_STATS_2 en la tabla ALC_SYTEM_MEM_STATS_IPRAN_RAW
  */
  PROCEDURE ALC_S_M_S_IPRAN_RAW_INS(P_FECHAHORA IN VARCHAR2);
  /**
  * Inserta los datos de laS tabla XML_NTWQOS en la tabla ALC_LAGS_IPRAN_SCNEOLR_RAW
  */
  PROCEDURE ALC_L_I_SCNEOLR_RAW_INS(P_FECHAHORA IN VARCHAR2);
  /**
  * Inserta los datos de laS tabla XML_NTWQOS_1 en la tabla ALC_LAGS_IPRAN_SCNIOLR_RAW
  */
  PROCEDURE ALC_L_I_SCNIOLR_RAW_INS(P_FECHAHORA IN VARCHAR2);
  /**
  * Insert los datos de la tabla XML_CARD_STATUS en la tabla ALC_CARDSLOT_IPRAN_OBJ
  */
  PROCEDURE ALC_CARDSLOT_IPRAN_OBJ_INS(P_FECHA IN VARCHAR2);
  /**
  * Insert los datos de la tabla XML_MEDIA_INDP_STATS en la tabla ALC_PHYSICALPORT_IPRAN_OBJ
  */
  PROCEDURE ALC_PHYSICALPORT_IPRAN_OBJ_INS(P_FECHA IN VARCHAR2);
END G_ALC_IPRAN;
/


CREATE OR REPLACE PACKAGE BODY G_ALC_IPRAN AS

  FUNCTION GET_XML_M_I_STATS_1_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_M_I_S_IPRAN_RAW_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    
    FOR fila IN (SELECT FECHA                         ,
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
                        TIME_CAPTURED                 ,
                        PERIODIC_TIME	                ,
                        MONITORED_OBJECT_POINTER	    ,
                        MONITORED_OBJECT_SITE_ID	    ,
                        MONITORED_OBJECT_SITENAME	    ,
                        ROUND(DECODE(OUTPUT_SPEED,0,0,8*RECEIVED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)),2) IN_BANDWITH_UTIL,
                        ROUND(DECODE(OUTPUT_SPEED,0,0,8*TRANSMITTED_OCTETS_PERIODIC/(OUTPUT_SPEED*900000)),2) OUT_BANDWITH_UTIL,
                        ROUND(RECEIVED_OCTETS_PERIODIC/1048576,2) REC_OCTETS,
                        ROUND(TRANSMITTED_OCTETS_PERIODIC/1048576,2) TRANS_OCTETS
                    FROM XML_MEDIA_INDEPEND_STATS_1
                    WHERE TO_CHAR(FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
        PIPE ROW (ALC_M_I_S_IPRAN_RAW_ROW(fila.FECHA,
                                          fila.DROP_EVENTS_PERIODIC,
                                          fila.DROPPED_FRAMES_PERIODIC,
                                          fila.RECEIVED_PACKETS_PERIODIC,
                                          fila.TRANSMITTED_PACKETS_PERIODIC,
                                          fila.RECEIVED_OCTETS_PERIODIC,
                                          fila.TRANSMITTED_OCTETS_PERIODIC,
                                          fila.REC_NON_UNICAST_PAC_PERIODIC,
                                          fila.TRAN_NON_UNICAST_PAC_PERIODIC,
                                          fila.RECEIVED_BAD_PACKETS_PERIODIC,
                                          fila.TRAN_BAD_PACKETS_PERIODIC,
                                          fila.INPUT_SPEED,
                                          fila.OUTPUT_SPEED,
                                          fila.DUPLEX,
                                          fila.DUPLEX_CHANGES_PERIODIC,
                                          fila.TIME_CAPTURED,
                                          fila.PERIODIC_TIME,
                                          fila.MONITORED_OBJECT_POINTER,
                                          fila.MONITORED_OBJECT_SITE_ID,
                                          fila.MONITORED_OBJECT_SITENAME,
                                          fila.IN_BANDWITH_UTIL,
                                          fila.OUT_BANDWITH_UTIL,
                                          fila.REC_OCTETS,
                                          fila.TRANS_OCTETS));
    END LOOP;
    RETURN;
  END GET_XML_M_I_STATS_1_DATA;
--**--**--**--
  PROCEDURE ALC_M_I_S_IPRAN_RAW_INS(P_FECHAHORA IN VARCHAR2) AS
  --
    CURSOR  DATOS(FECHAHORA VARCHAR2) IS
    SELECT  FECHA                         ,
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
            TRANS_OCTETS
    FROM TABLE(G_ALC_IPRAN.GET_XML_M_I_STATS_1_DATA(FECHAHORA));
    --
    TYPE TY_ALC_M_I_S_IPRAN_RAW IS TABLE OF ALC_MEDIA_INDP_STATS_IPRAN_RAW%ROWTYPE;
    V_ALC_M_I_S_IPRAN_RAW TY_ALC_M_I_S_IPRAN_RAW;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
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
      FETCH DATOS BULK COLLECT INTO V_ALC_M_I_S_IPRAN_RAW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_M_I_S_IPRAN_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_MEDIA_INDP_STATS_IPRAN_RAW VALUES V_ALC_M_I_S_IPRAN_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_M_I_S_IPRAN_RAW_INS',
                                                L_ERRNO,
                                                L_MSG,
                                                'FECHA -->'                         ||V_ALC_M_I_S_IPRAN_RAW(L_IDX).FECHA||' '||
                                                'DROP_EVENTS_PERIODIC  -->'         ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).DROP_EVENTS_PERIODIC)||' '||
                                                'DROPPED_FRAMES_PERIODIC -->'       ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).DROPPED_FRAMES_PERIODIC)||' '||
                                                'RECEIVED_PACKETS_PERIODIC -->'     ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).RECEIVED_PACKETS_PERIODIC)||' '||
                                                'TRANSMITTED_PACKETS_PERIODIC -->'  ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).TRANSMITTED_PACKETS_PERIODIC)||' '||
                                                'RECEIVED_OCTETS_PERIODIC -->'      ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).RECEIVED_OCTETS_PERIODIC)||' '||
                                                'TRANSMITTED_OCTETS_PERIODIC -->'   ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).TRANSMITTED_OCTETS_PERIODIC)||' '||
                                                'REC_NON_UNICAST_PAC_PERIODIC -->'  ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).REC_NON_UNICAST_PAC_PERIODIC)||' '||
                                                'TRAN_NON_UNICAST_PAC_PERIODIC -->' ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).TRAN_NON_UNICAST_PAC_PERIODIC)||' '||
                                                'RECEIVED_BAD_PACKETS_PERIODIC -->' ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).RECEIVED_BAD_PACKETS_PERIODIC)||' '||
                                                'TRAN_BAD_PACKETS_PERIODIC -->'     ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).TRAN_BAD_PACKETS_PERIODIC)||' '||
                                                'INPUT_SPEED -->'                   ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).INPUT_SPEED)||' '||
                                                'OUTPUT_SPEED -->'                  ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).OUTPUT_SPEED)||' '||
                                                'DUPLEX -->'                        ||V_ALC_M_I_S_IPRAN_RAW(L_IDX).DUPLEX||' '||
                                                'DUPLEX_CHANGESPERIODIC -->'        ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).DUPLEX_CHANGESPERIODIC)||' '||
                                                'TIME_CAPTURED -->'                 ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).TIME_CAPTURED)||' '||
                                                'PERIODIC_TIME -->'                 ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).PERIODIC_TIME)||' '||
                                                'MONITORED_OBJECT_POINTER -->'      ||V_ALC_M_I_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_POINTER||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'      ||V_ALC_M_I_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_SITE_ID||' '||
                                                'MONITORED_OBJECT_SITENAME -->'     ||V_ALC_M_I_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_SITENAME||' '||
                                                'IN_BANDWITH_UTIL -->'              ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).IN_BANDWITH_UTIL)||' '||
                                                'OUT_BANDWITH_UTIL -->'             ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).OUT_BANDWITH_UTIL)||' '||
                                                'REC_OCTETS -->'                    ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).REC_OCTETS)||' '||
                                                'TRANS_OCTETS -->'                  ||TO_CHAR(V_ALC_M_I_S_IPRAN_RAW(L_IDX).TRANS_OCTETS));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;    
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      --DBMS_OUTPUT.PUT_LINE(SQLERRM);
      G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_M_I_S_IPRAN_RAW_INS',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END ALC_M_I_S_IPRAN_RAW_INS;
--**--**--**--
  FUNCTION GET_XML_SYSTEM_STATS_3_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_S_C_S_IPRAN_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    FOR fila IN (SELECT FECHA                       ,
                        SYSTEM_CPU_USAGE	          ,
                        TIME_CAPTURED	              ,
                        PERIODIC_TIME	              ,
                        MONITORED_OBJECT_SITE_ID    ,
                        MONITORED_OBJECT_SITE_NAME
                FROM  XML_SYSTEM_STATS_3
                WHERE TO_CHAR(FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
      PIPE ROW (ALC_S_C_S_IPRAN_ROW(fila.FECHA,fila.SYSTEM_CPU_USAGE,fila.TIME_CAPTURED,fila.PERIODIC_TIME,
                                    fila.MONITORED_OBJECT_SITE_ID,fila.MONITORED_OBJECT_SITE_NAME));
    END LOOP;
    RETURN;
  END GET_XML_SYSTEM_STATS_3_DATA;
  --**--**--**
  PROCEDURE ALC_S_C_S_IPRAN_RAW_INS(P_FECHAHORA IN VARCHAR2) AS
    --
    CURSOR DATOS(FECHA_HORA VARCHAR2) IS
    SELECT  FECHA                       ,
            SYSTEM_CPU_USAGE	          ,
            TIME_CAPTURED	              ,
            PERIODIC_TIME	              ,
            MONITORED_OBJECT_SITE_ID    ,
            MONITORED_OBJECT_SITE_NAME
    FROM  TABLE(GET_XML_SYSTEM_STATS_3_DATA(FECHA_HORA));
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_S_C_S_IPRAN_RAW IS TABLE OF ALC_SYSTEM_CPU_STATS_IPRAN_RAW%ROWTYPE;
    V_ALC_S_C_S_IPRAN_RAW TY_ALC_S_C_S_IPRAN_RAW;
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
      FETCH DATOS BULK COLLECT INTO V_ALC_S_C_S_IPRAN_RAW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_S_C_S_IPRAN_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_SYSTEM_CPU_STATS_IPRAN_RAW VALUES V_ALC_S_C_S_IPRAN_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_S_C_S_IPRAN_RAW_INS',L_ERRNO,L_MSG,
                                                'FECHA -->'                      ||V_ALC_S_C_S_IPRAN_RAW(L_IDX).FECHA||' '||
                                                'SYSTEM_CPU_USAGE -->'           ||TO_CHAR(V_ALC_S_C_S_IPRAN_RAW(L_IDX).SYSTEM_CPU_USAGE)||' '||                                                
                                                'TIME_CAPTURED  -->'             ||TO_CHAR(V_ALC_S_C_S_IPRAN_RAW(L_IDX).TIME_CAPTURED)||' '||
                                                'PERIODIC_TIME -->'              ||TO_CHAR(V_ALC_S_C_S_IPRAN_RAW(L_IDX).PERIODIC_TIME)||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'   ||V_ALC_S_C_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_SITE_ID||' '||                                                
                                                'MONITORED_OBJECT_SITE_NAME -->' ||V_ALC_S_C_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_SITE_NAME);
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_S_C_S_IPRAN_RAW_INS',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END ALC_S_C_S_IPRAN_RAW_INS;
  --**--**--**--
  FUNCTION GET_XML_SYSTEM_STATS_1_2_DATA(P_FECHAHORA  IN VARCHAR2) RETURN ALC_S_M_S_IPRAN_RAW_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    FOR fila IN (SELECT SMS.FECHA                                                FECHA,
                      SMS.SYSTEM_MEMORY_USAGE	                                                              SYSTEM_MEMORY_USAGE,
                      SMS.TIME_CAPTURED		                                                                  SMS_TIME_CAPTURED,
                      SMS.PERIODIC_TIME		                                                                  SMS_PERIODIC_TIME,
                      SMS.MONITORED_OBJECT_SITE_ID	                                                        MONITORED_OBJECT_SITE_ID,
                      SMS.MONITORED_OBJECT_SITE_NAME	                                                      MONITORED_OBJECT_SITE_NAME,
                      ROUND(SMS.SYSTEM_MEMORY_USAGE/1048576,2)                                              SMS_SYSTEM_MEMORY_USAGE_MB,
                      ROUND(DECODE((AVMS.AVAILABLE_MEMORY + AMS.ALLOCATED_MEMORY),0,0,
                            (SMS.SYSTEM_MEMORY_USAGE / (AVMS.AVAILABLE_MEMORY + AMS.ALLOCATED_MEMORY))),2)  SMS_SYSTEM_MEMORY_USAGE_AVG,
                      AVMS.AVAILABLE_MEMORY		                                                              AVAILABLE_MEMORY,
                      AVMS.TIME_CAPTURED		                                                                AVMS_TIME_CAPTURED,
                      AVMS.PERIODIC_TIME		                                                                AVMS_PERIODIC_TIME,
                      ROUND(DECODE((AVMS.AVAILABLE_MEMORY + AMS.ALLOCATED_MEMORY),0,0,
                            (AVMS.AVAILABLE_MEMORY / (AVMS.AVAILABLE_MEMORY + AMS.ALLOCATED_MEMORY))),2)    AVMS_AVAILABLE_MEMORY_PCT,
                      ROUND(AVMS.AVAILABLE_MEMORY/1048576,2)                                                AVMS_AVAILABLE_MEMORY_MB,
                      AMS.ALLOCATED_MEMORY		                                                              ALLOCATED_MEMORY,
                      AMS.TIME_CAPTURED		                                                                  AMS_TIME_CAPTURED,
                      AMS.PERIODIC_TIME		                                                                  AMS_PERIODIC_TIME,
                      ROUND(AMS.ALLOCATED_MEMORY / 1048576,2)                                               AMS_ALLOCATED_MEMORY_MB                
                FROM  XML_SYSTEM_STATS SMS,
                      XML_SYSTEM_STATS_1 AVMS,
                      XML_SYSTEM_STATS_2 AMS
                WHERE SMS.FECHA = AVMS.FECHA
                AND   AVMS.FECHA = AMS.FECHA
                AND   SMS.MONITORED_OBJECT_SITE_NAME = AVMS.MONITORED_OBJECT_SITE_NAME
                AND   AVMS.MONITORED_OBJECT_SITE_NAME = AMS.MONITORED_OBJECT_SITE_NAME
                AND   TO_CHAR(SMS.FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
      PIPE ROW (ALC_S_M_S_IPRAN_RAW_ROW(fila.FECHA,
                                        fila.SYSTEM_MEMORY_USAGE,
                                        fila.SMS_TIME_CAPTURED,
                                        fila.SMS_PERIODIC_TIME,
                                        fila.MONITORED_OBJECT_SITE_ID,
                                        fila.MONITORED_OBJECT_SITE_NAME,
                                        fila.SMS_SYSTEM_MEMORY_USAGE_MB,
                                        fila.SMS_SYSTEM_MEMORY_USAGE_AVG,
                                        fila.AVAILABLE_MEMORY,
                                        fila.AVMS_TIME_CAPTURED,
                                        fila.AVMS_PERIODIC_TIME,
                                        fila.AVMS_AVAILABLE_MEMORY_PCT,
                                        fila.AVMS_AVAILABLE_MEMORY_MB,
                                        fila.ALLOCATED_MEMORY,
                                        fila.AMS_TIME_CAPTURED,
                                        fila.AMS_PERIODIC_TIME,
                                        fila.AMS_ALLOCATED_MEMORY_MB));
    END LOOP;
    RETURN;
  END GET_XML_SYSTEM_STATS_1_2_DATA;
  --**--**--**--
  PROCEDURE ALC_S_M_S_IPRAN_RAW_INS(P_FECHAHORA IN VARCHAR2) AS
    --
    CURSOR DATOS (FECHA_HORA VARCHAR2) IS
    SELECT  FECHA,
            SYSTEM_MEMORY_USAGE,
            SMS_TIME_CAPTURED,
            SMS_PERIODIC_TIME,
            MONITORED_OBJECT_SITE_ID,
            MONITORED_OBJECT_SITE_NAME,
            SMS_SYSTEM_MEMORY_USAGE_MB,
            SMS_SYSTEM_MEMORY_USAGE_AVG,
            AVAILABLE_MEMORY,
            AVMS_TIME_CAPTURED,
            AVMS_PERIODIC_TIME,
            AVMS_AVAILABLE_MEMORY_PCT,
            AVMS_AVAILABLE_MEMORY_MB,
            ALLOCATED_MEMORY,
            AMS_TIME_CAPTURED,
            AMS_PERIODIC_TIME,
            AMS_ALLOCATED_MEMORY_MB
    FROM  TABLE(GET_XML_SYSTEM_STATS_1_2_DATA(FECHA_HORA));
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_S_M_S_IPRAN_RAW IS TABLE OF ALC_SYSTEM_MEM_STATS_IPRAN_RAW%ROWTYPE;
    V_ALC_S_M_S_IPRAN_RAW TY_ALC_S_M_S_IPRAN_RAW;
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
      FETCH DATOS BULK COLLECT INTO V_ALC_S_M_S_IPRAN_RAW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_S_M_S_IPRAN_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_SYSTEM_MEM_STATS_IPRAN_RAW VALUES V_ALC_S_M_S_IPRAN_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_S_M_S_IPRAN_RAW_INS',L_ERRNO,L_MSG,
                                                'FECHA -->'                       ||V_ALC_S_M_S_IPRAN_RAW(L_IDX).FECHA||' '||
                                                'SYSTEM_MEMORY_USAGE -->'         ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).SYSTEM_MEMORY_USAGE)||' '||                                                
                                                'SMS_TIME_CAPTURED  -->'          ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).SMS_TIME_CAPTURED)||' '||
                                                'SMS_PERIODIC_TIME -->'           ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).SMS_PERIODIC_TIME)||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'    ||V_ALC_S_M_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_SITE_ID||' '||           
                                                'MONITORED_OBJECT_SITE_NAME -->'  ||V_ALC_S_M_S_IPRAN_RAW(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||                                                
                                                'SMS_SYSTEM_MEMORY_USAGE_MB -->'  ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).SMS_SYSTEM_MEMORY_USAGE_MB)||' '||                                                
                                                'SMS_SYSTEM_MEMORY_USAGE_AVG -->' ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).SMS_SYSTEM_MEMORY_USAGE_AVG)||' '||                                                
                                                'AVAILABLE_MEMORY -->'            ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AVAILABLE_MEMORY)||' '||                                                
                                                'AVMS_TIME_CAPTURED -->'          ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AVMS_TIME_CAPTURED)||' '||                                                
                                                'AVMS_PERIODIC_TIME -->'          ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AVMS_PERIODIC_TIME)||' '||                                                
                                                'AVMS_AVAILABLE_MEMORY_PCT -->'   ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AVMS_AVAILABLE_MEMORY_PCT)||' '||                                                
                                                'AVMS_AVAILABLE_MEMORY_MB -->'    ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AVMS_AVAILABLE_MEMORY_MB)||' '||                                                
                                                'ALLOCATED_MEMORY -->'            ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).ALLOCATED_MEMORY)||' '||                                                
                                                'AMS_TIME_CAPTURED -->'           ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AMS_TIME_CAPTURED)||' '||
                                                'AMS_PERIODIC_TIME -->'           ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AMS_PERIODIC_TIME)||' '||
                                                'AMS_ALLOCATED_MEMORY_MB -->'     ||TO_CHAR(V_ALC_S_M_S_IPRAN_RAW(L_IDX).AMS_ALLOCATED_MEMORY_MB));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_S_M_S_IPRAN_RAW_INS',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  
  END ALC_S_M_S_IPRAN_RAW_INS;
  --**--**--**--
  FUNCTION GET_XML_NTWQOS_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_L_IPRAN_SCNEOLR_RAW_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    FOR fila IN (SELECT FECHA,
                        PORT_ID,
                        QUEUE_ID,
                        LAG_PORT,
                        TIME_RECORDED,
                        IN_PROFILE_OCTETS_FORWARDED,
                        IN_PROFILE_OCTETS_DROPPED,
                        OUT_OF_PROFILE_OCTETS_FWDED,
                        OUT_OF_PROFILE_OCTETS_DROPPED,
                        MONITORED_OBJECT_SITE_ID,
                        MONITORED_OBJECT_SITE_NAME
                FROM XML_NTWQOS
                WHERE TO_CHAR(FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
    PIPE ROW (ALC_L_IPRAN_SCNEOLR_RAW_ROW(fila.FECHA,fila.PORT_ID,fila.QUEUE_ID,fila.LAG_PORT,fila.TIME_RECORDED,
                        fila.IN_PROFILE_OCTETS_FORWARDED,fila.IN_PROFILE_OCTETS_DROPPED,fila.OUT_OF_PROFILE_OCTETS_FWDED,
                        fila.OUT_OF_PROFILE_OCTETS_DROPPED,fila.MONITORED_OBJECT_SITE_ID,fila.MONITORED_OBJECT_SITE_NAME));
  END LOOP;
  RETURN;
  END GET_XML_NTWQOS_DATA;
  --**--**--**--
  PROCEDURE ALC_L_I_SCNEOLR_RAW_INS(P_FECHAHORA IN VARCHAR2) AS
    CURSOR DATOS(FECHA_HORA VARCHAR2) IS
    SELECT  FECHA,
            PORT_ID,
            QUEUE_ID,
            LAG_PORT,
            TIME_RECORDED,
            IN_PROFILE_OCTETS_FORWARDED,
            IN_PROFILE_OCTETS_DROPPED,
            OUT_OF_PROFILE_OCTETS_FWDED,
            OUT_OF_PROFILE_OCTETS_DROPPED,
            MONITORED_OBJECT_SITE_ID,
            MONITORED_OBJECT_SITE_NAME
    FROM TABLE(GET_XML_NTWQOS_DATA(P_FECHAHORA));
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_L_IPRAN_SCNEOLR_RAW IS TABLE OF ALC_LAGS_IPRAN_SCNEOLR_RAW%ROWTYPE;
    V_ALC_L_IPRAN_SCNEOLR_RAW TY_ALC_L_IPRAN_SCNEOLR_RAW;
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
      FETCH DATOS BULK COLLECT INTO V_ALC_L_IPRAN_SCNEOLR_RAW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_L_IPRAN_SCNEOLR_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_LAGS_IPRAN_SCNEOLR_RAW VALUES V_ALC_L_IPRAN_SCNEOLR_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_S_M_S_IPRAN_RAW_INS',L_ERRNO,L_MSG,
                                                'FECHA -->'                         ||V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).FECHA||' '||
                                                'PORT_ID -->'                       ||V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).PORT_ID||' '||                                                
                                                'QUEUE_ID  -->'                     ||TO_CHAR(V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).QUEUE_ID)||' '||
                                                'LAG_PORT -->'                      ||V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).LAG_PORT||' '||
                                                'TIME_RECORDED -->'                 ||TO_CHAR(V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).TIME_RECORDED)||' '||
                                                'IN_PROFILE_OCTETS_FORWARDED -->'   ||TO_CHAR(V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).IN_PROFILE_OCTETS_FORWARDED)||' '||
                                                'IN_PROFILE_OCTETS_DROPPED -->'     ||TO_CHAR(V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).IN_PROFILE_OCTETS_DROPPED)||' '||
                                                'OUT_OF_PROFILE_OCTETS_FWDED -->'   ||TO_CHAR(V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).OUT_OF_PROFILE_OCTETS_FWDED)||' '||
                                                'OUT_OF_PROFILE_OCTETS_DROPPED -->' ||TO_CHAR(V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).OUT_OF_PROFILE_OCTETS_DROPPED)||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'      ||V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).MONITORED_OBJECT_SITE_ID||' '||
                                                'MONITORED_OBJECT_SITE_NAME -->'    ||V_ALC_L_IPRAN_SCNEOLR_RAW(L_IDX).MONITORED_OBJECT_SITE_NAME);
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_L_I_SCNEOLR_RAW_INS',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END ALC_L_I_SCNEOLR_RAW_INS;
  --**--**--**--
  FUNCTION GET_XML_NTWQOS_1_DATA(P_FECHAHORA IN VARCHAR2) RETURN ALC_L_IPRAN_SCNIOLR_RAW_TY PIPELINED AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    FOR fila IN (SELECT FECHA,
                        PORT_ID,
                        QUEUE_ID,
                        LAG_PORT,
                        TIME_RECORDED,
                        IN_PROFILE_OCTETS_FORWARDED,
                        IN_PROFILE_OCTETS_DROPPED,
                        OUT_OF_PROFILE_OCTETS_FWDED,
                        OUT_OF_PROFILE_OCTETS_DROPPED,
                        MONITORED_OBJECT_SITE_ID,
                        MONITORED_OBJECT_SITE_NAME
                FROM XML_NTWQOS_1
                WHERE TO_CHAR(FECHA,'DD.MM.YYYY HH24') = P_FECHAHORA) LOOP
    PIPE ROW (ALC_L_IPRAN_SCNIOLR_RAW_ROW(fila.FECHA,fila.PORT_ID,fila.QUEUE_ID,fila.LAG_PORT,fila.TIME_RECORDED,
                        fila.IN_PROFILE_OCTETS_FORWARDED,fila.IN_PROFILE_OCTETS_DROPPED,fila.OUT_OF_PROFILE_OCTETS_FWDED,
                        fila.OUT_OF_PROFILE_OCTETS_DROPPED,fila.MONITORED_OBJECT_SITE_ID,fila.MONITORED_OBJECT_SITE_NAME));
  END LOOP;
  RETURN;
  END GET_XML_NTWQOS_1_DATA;
  --**--**--**--
  PROCEDURE ALC_L_I_SCNIOLR_RAW_INS(P_FECHAHORA IN VARCHAR2) AS
    CURSOR DATOS(FECHA_HORA VARCHAR2) IS
    SELECT  FECHA,
            PORT_ID,
            QUEUE_ID,
            LAG_PORT,
            TIME_RECORDED,
            IN_PROFILE_OCTETS_FORWARDED,
            IN_PROFILE_OCTETS_DROPPED,
            OUT_OF_PROFILE_OCTETS_FWDED,
            OUT_OF_PROFILE_OCTETS_DROPPED,
            MONITORED_OBJECT_SITE_ID,
            MONITORED_OBJECT_SITE_NAME
    FROM TABLE(GET_XML_NTWQOS_1_DATA(P_FECHAHORA));
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_L_IPRAN_SCNIOLR_RAW IS TABLE OF ALC_LAGS_IPRAN_SCNIOLR_RAW%ROWTYPE;
    V_ALC_L_IPRAN_SCNIOLR_RAW TY_ALC_L_IPRAN_SCNIOLR_RAW;
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
      FETCH DATOS BULK COLLECT INTO V_ALC_L_IPRAN_SCNIOLR_RAW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_L_IPRAN_SCNIOLR_RAW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_LAGS_IPRAN_SCNIOLR_RAW VALUES V_ALC_L_IPRAN_SCNIOLR_RAW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_L_I_SCNIOLR_RAW_INS',L_ERRNO,L_MSG,
                                                'FECHA -->'                         ||V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).FECHA||' '||
                                                'PORT_ID -->'                       ||V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).PORT_ID||' '||                                                
                                                'QUEUE_ID  -->'                     ||TO_CHAR(V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).QUEUE_ID)||' '||
                                                'LAG_PORT -->'                      ||V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).LAG_PORT||' '||
                                                'TIME_RECORDED -->'                 ||TO_CHAR(V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).TIME_RECORDED)||' '||
                                                'IN_PROFILE_OCTETS_FORWARDED -->'   ||TO_CHAR(V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).IN_PROFILE_OCTETS_FORWARDED)||' '||
                                                'IN_PROFILE_OCTETS_DROPPED -->'     ||TO_CHAR(V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).IN_PROFILE_OCTETS_DROPPED)||' '||
                                                'OUT_OF_PROFILE_OCTETS_FWDED -->'   ||TO_CHAR(V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).OUT_OF_PROFILE_OCTETS_FWDED)||' '||
                                                'OUT_OF_PROFILE_OCTETS_DROPPED -->' ||TO_CHAR(V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).OUT_OF_PROFILE_OCTETS_DROPPED)||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'      ||V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).MONITORED_OBJECT_SITE_ID||' '||
                                                'MONITORED_OBJECT_SITE_NAME -->'    ||V_ALC_L_IPRAN_SCNIOLR_RAW(L_IDX).MONITORED_OBJECT_SITE_NAME);
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_L_I_SCNIOLR_RAW_INS',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END ALC_L_I_SCNIOLR_RAW_INS;
  --**--**--**--
  PROCEDURE ALC_CARDSLOT_IPRAN_OBJ_INS(P_FECHA IN VARCHAR2) AS
    
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    -- Agrego los datos de la tabla XML_CARD_STATUS a la tabla ALC_CARDSLOT_IPRAN_OBJ
    BEGIN
      -- MERGE 1
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
                            WHERE TO_CHAR(FECHA,'YYYYMMDD') = P_FECHA) --SUBSTR(P_FECHA,1,8))
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
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_CARDSLOT_IPRAN_OBJ_INS',SQLCODE,SQLERRM,'MERGE A --> '||DBMS_UTILITY.format_error_backtrace );
    END;
    -- MERGE 2
    BEGIN
    --
      -- Merge B: actualizar los datos que estan en ALC_CARDSLOT_IPRAN_OBJ que no estan en XML_CARD_STATUS,
      -- update VALID_FINISH_DATE = sysdate     
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
                                                    WHERE TO_CHAR(FECHA,'YYYYMMDD') = P_FECHA --SUBSTR(P_FECHA,1,8)
                                                    )
                                              WHERE RN = 1);
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_CARDSLOT_IPRAN_OBJ_INS',SQLCODE,SQLERRM,'MERGE B --> '||DBMS_UTILITY.format_error_backtrace );
    END;
  END ALC_CARDSLOT_IPRAN_OBJ_INS;
  --**--**--**--
  PROCEDURE ALC_PHYSICALPORT_IPRAN_OBJ_INS(P_FECHA IN VARCHAR2) AS
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    -- Merge A: los datos de XML_MEDIA_INDP_STATS que no esten en ALC_PHYSICALPORT_IPRAN_OBJ se agregan.....
    BEGIN
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
                            FROM XML_MEDIA_INDEPEND_STATS
                            WHERE TO_CHAR(FECHA,'YYYYMMDD') = P_FECHA) --SUBSTR(P_FECHA,1,8))
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
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_PHYSICALPORT_IPRAN_OBJ_INS',SQLCODE,SQLERRM,'MERGE A --> '||DBMS_UTILITY.format_error_backtrace );
    END;
    BEGIN
      -- Merge B: actualizar los datos que estan en ALC_PHYSICALPORT_IPRAN_OBJ que no estan en XML_MEDIA_INDEPEND_STATS,
      -- update VALID_FINISH_DATE = sysdate
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
                                                                      WHERE TO_CHAR(FECHA,'YYYYMMDD') = SUBSTR(P_FECHA,1,8)
                                                                      )
                                                                WHERE RN = 1);
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('ALC_PHYSICALPORT_IPRAN_OBJ_INS',SQLCODE,SQLERRM,'MERGE B --> '||DBMS_UTILITY.format_error_backtrace );
    END;
  END ALC_PHYSICALPORT_IPRAN_OBJ_INS;
  
END G_ALC_IPRAN;
/
