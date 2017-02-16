create or replace PACKAGE BODY G_ALC_IPRAN AS

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
                        ROUND(RECEIVED_OCTETS_PERIODIC * 8 / (60 * 60),2) REC_OCTETS,
                        ROUND(TRANSMITTED_OCTETS_PERIODIC * 8 / (60 * 60),2) TRANS_OCTETS
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
  PROCEDURE INS_ALC_M_I_S_IPRAN_RAW(P_FECHAHORA IN VARCHAR2) AS
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
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_M_I_S_IPRAN_RAW',
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
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_M_I_S_IPRAN_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END INS_ALC_M_I_S_IPRAN_RAW;
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
  PROCEDURE INS_ALC_S_C_S_IPRAN_RAW(P_FECHAHORA IN VARCHAR2) AS
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
    --
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
            WHEN DUP_VAL_ON_INDEX THEN
              NULL;
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_S_C_S_IPRAN_RAW',L_ERRNO,L_MSG,
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
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_S_C_S_IPRAN_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_S_C_S_IPRAN_RAW;
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
  PROCEDURE INS_ALC_S_M_S_IPRAN_RAW(P_FECHAHORA IN VARCHAR2) AS
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
    FROM  TABLE(G_ALC_IPRAN.GET_XML_SYSTEM_STATS_1_2_DATA(FECHA_HORA));
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
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_S_M_S_IPRAN_RAW',L_ERRNO,L_MSG,
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
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_S_M_S_IPRAN_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  
  END INS_ALC_S_M_S_IPRAN_RAW;
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
  PROCEDURE INS_ALC_L_I_SCNEOLR_RAW(P_FECHAHORA IN VARCHAR2) AS
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
    FROM TABLE(G_ALC_IPRAN.GET_XML_NTWQOS_DATA(FECHA_HORA));
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
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_S_M_S_IPRAN_RAW',L_ERRNO,L_MSG,
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
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_L_I_SCNEOLR_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END INS_ALC_L_I_SCNEOLR_RAW;
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
  PROCEDURE INS_ALC_L_I_SCNIOLR_RAW(P_FECHAHORA IN VARCHAR2) AS
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
    FROM TABLE(GET_XML_NTWQOS_1_DATA(FECHA_HORA));
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
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_L_I_SCNIOLR_RAW',L_ERRNO,L_MSG,
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
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_L_I_SCNIOLR_RAW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  END INS_ALC_L_I_SCNIOLR_RAW;
  --**--**--**--
  PROCEDURE INS_ALC_CARDSLOT_IPRAN_OBJ(P_FECHA IN VARCHAR2) AS
    V_FECHA VARCHAR2(10 CHAR) := '';
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    -- Agrego los datos de la tabla XML_CARD_STATUS a la tabla ALC_CARDSLOT_IPRAN_OBJ
    BEGIN
      -- Calculo la fecha de ayer
      SELECT TO_CHAR(TO_DATE(P_FECHA,'DDMMYYYY')-1,'DDMMYYYY') 
      INTO V_FECHA
      FROM DUAL;
      -- MERGE 1
      MERGE INTO ALC_CARDSLOT_IPRAN_OBJ ALC
      USING (WITH DATOS AS  (SELECT  /*+ INLINE */
                                    TO_CHAR(FECHA,'DDMMYYYY') VALID_START_DATE
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
                            WHERE TO_CHAR(FECHA,'DDMMYYYY') = V_FECHA)
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
          G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_CARDSLOT_IPRAN_OBJ',SQLCODE,SQLERRM,'MERGE A --> '||DBMS_UTILITY.format_error_backtrace );
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
                                              FROM  (SELECT  /*+ INLINE */
                                                            SITE_NAME
                                                            ,OBJECT_FULL_NAME
                                                            ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,OBJECT_FULL_NAME 
                                                                                ORDER BY SITE_NAME,OBJECT_FULL_NAME) RN
                                                    FROM XML_CARD_STATUS
                                                    WHERE TO_CHAR(FECHA,'DDMMYYYY') = V_FECHA
                                                    )
                                              WHERE RN = 1
                                              MINUS
                                              SELECT  SITE_NAME
                                                      ,OBJECT_FULL_NAME
                                              FROM  ALC_CARDSLOT_IPRAN_OBJ
                                              WHERE VALID_FINISH_DATE > SYSDATE
                                              );
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_CARDSLOT_IPRAN_OBJ',SQLCODE,SQLERRM,'MERGE B --> '||DBMS_UTILITY.format_error_backtrace );
    END;
  END INS_ALC_CARDSLOT_IPRAN_OBJ;
  --**--**--**--
  PROCEDURE INS_ALC_PHYSICALPORT_IPRAN_OBJ(P_FECHA IN VARCHAR2) AS
    V_FECHA VARCHAR2(10 CHAR) := '';
    BEGIN
      -- Calculo la fecha de ayer
      SELECT TO_CHAR(TO_DATE(P_FECHA,'DDMMYYYY')-1,'DDMMYYYY') 
      INTO V_FECHA
      FROM DUAL;
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    -- Merge A: los datos de XML_MEDIA_INDP_STATS que no esten en ALC_PHYSICALPORT_IPRAN_OBJ se agregan.....
    BEGIN
      MERGE INTO ALC_PHYSICALPORT_IPRAN_OBJ ALC
      USING (WITH DATOS AS  (SELECT  /*+ INLINE */
                                    TO_CHAR(FECHA,'DDMMYYYY') VALID_START_DATE
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
                            WHERE TO_CHAR(FECHA,'DDMMYYYY') = V_FECHA)
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
          G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_PHYSICALPORT_IPRAN_OBJ',SQLCODE,SQLERRM,'MERGE A --> '||DBMS_UTILITY.format_error_backtrace );
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
                                                                FROM  (SELECT  /*+ INLINE */
                                                                              MAC_ADDRESS
                                                                              ,SITE_ID
                                                                              ,SITE_NAME
                                                                              ,OBJECT_FULL_NAME
                                                                              ,ROW_NUMBER() OVER (PARTITION BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME 
                                                                                                  ORDER BY SITE_NAME,SITE_ID,MAC_ADDRESS,OBJECT_FULL_NAME) RN
                                                                      FROM XML_MEDIA_INDEPEND_STATS
                                                                      WHERE TO_CHAR(FECHA,'DDMMYYYY') = V_FECHA
                                                                      )
                                                                WHERE RN = 1
                                                                MINUS
                                                                SELECT  SITE_ID
                                                                        ,SITE_NAME
                                                                        ,MAC_ADDRESS
                                                                        ,OBJECT_FULL_NAME
                                                                FROM  ALC_PHYSICALPORT_IPRAN_OBJ
                                                                WHERE VALID_FINISH_DATE > SYSDATE);
      COMMIT;
      EXCEPTION
        WHEN OTHERS THEN
          G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_PHYSICALPORT_IPRAN_OBJ',SQLCODE,SQLERRM,'MERGE B --> '||DBMS_UTILITY.format_error_backtrace );
    END;
  END INS_ALC_PHYSICALPORT_IPRAN_OBJ;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_IPRAN_HOUR(P_FECHAHORA IN VARCHAR2) AS
    --
    CURSOR  DATOS(FECHA_HORA VARCHAR2) IS
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
    WHERE TO_CHAR(FECHA,'DDMMYYYYHH24') = FECHA_HORA
    GROUP BY  TO_CHAR(FECHA,'DD.MM.YYYY HH24')
              ,MONITORED_OBJECT_POINTER
              ,MONITORED_OBJECT_SITE_ID
              ,MONITORED_OBJECT_SITENAME;
  --
  --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_M_I_S_IPRAN_HOUR IS TABLE OF ALC_STATS_IPRAN_HOUR%ROWTYPE;
    V_ALC_M_I_S_IPRAN_HOUR TY_ALC_M_I_S_IPRAN_HOUR;
    --
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHAHORA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_M_I_S_IPRAN_HOUR LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_M_I_S_IPRAN_HOUR.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_IPRAN_HOUR VALUES V_ALC_M_I_S_IPRAN_HOUR(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;
                  
                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_HOUR',L_ERRNO,L_MSG,
                                                'FECHA -->'                         ||V_ALC_M_I_S_IPRAN_HOUR(L_IDX).FECHA||' '||
                                                'DROP_EVENTS_PERIODIC -->'          ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).DROP_EVENTS_PERIODIC)||' '||                                                
                                                'DROPPED_FRAMES_PERIODIC -->'       ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).DROPPED_FRAMES_PERIODIC)||' '||
                                                'RECEIVED_PACKETS_PERIODIC -->'     ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).RECEIVED_PACKETS_PERIODIC)||' '||
                                                'TRANSMITTED_PACKETS_PERIODIC -->'  ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).TRANSMITTED_PACKETS_PERIODIC)||' '||
                                                'RECEIVED_OCTETS_PERIODIC -->'      ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).RECEIVED_OCTETS_PERIODIC)||' '||
                                                'TRANSMITTED_OCTETS_PERIODIC -->'   ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).TRANSMITTED_OCTETS_PERIODIC)||' '||
                                                'RECEIVED_NON_UNI_PACK_PERIODIC -->'||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).RECEIVED_NON_UNI_PACK_PERIODIC)||' '||
                                                'TRANS_NON_UNI_PACK_PERIODIC -->'   ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).TRANS_NON_UNI_PACK_PERIODIC)||' '||
                                                'RECEIVED_BAD_PACKETS_PERIODIC -->' ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).RECEIVED_BAD_PACKETS_PERIODIC)||' '||
                                                'TRANS_BAD_PACKETS_PERIODIC -->'    ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).TRANS_BAD_PACKETS_PERIODIC)||' '||
                                                'INPUT_SPEED -->'                   ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).INPUT_SPEED)||' '||
                                                'OUTPUT_SPEED -->'                  ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).OUTPUT_SPEED)||' '||
                                                'MONITORED_OBJECT_POINTER -->'      ||V_ALC_M_I_S_IPRAN_HOUR(L_IDX).MONITORED_OBJECT_POINTER||' '||
                                                'MONITORED_OBJECT_SITEID -->'       ||V_ALC_M_I_S_IPRAN_HOUR(L_IDX).MONITORED_OBJECT_SITEID||' '||
                                                'MONITORED_OBJECT_SITE_NAME -->'    ||V_ALC_M_I_S_IPRAN_HOUR(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'IN_BANDWITH_UTIL -->'              ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).IN_BANDWITH_UTIL)||' '||
                                                'OUT_BANDWITH_UTIL -->'             ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).OUT_BANDWITH_UTIL)||' '||
                                                'REC_OCTETS -->'                    ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).REC_OCTETS)||' '||
                                                'TRANS_OCTETS -->'                  ||TO_CHAR(V_ALC_M_I_S_IPRAN_HOUR(L_IDX).TRANS_OCTETS));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_HOUR',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
  
  END INS_ALC_STATS_IPRAN_HOUR;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_IPRAN_DAY(P_FECHA IN VARCHAR2)  AS
    CURSOR  DATOS(DIA VARCHAR2) IS
    SELECT  TRUNC(FECHA)                                  FECHA
            ,MONITORED_OBJECT_POINTER
            ,MONITORED_OBJECT_SITEID
            ,MONITORED_OBJECT_SITE_NAME
            ,ROUND(SUM(DROP_EVENTS_PERIODIC),2)           DROP_EVENTS_PERIODIC
            ,ROUND(SUM(DROPPED_FRAMES_PERIODIC),2)        DROPPED_FRAMES_PERIODIC
            ,ROUND(SUM(RECEIVED_PACKETS_PERIODIC),2)      RECEIVED_PACKETS_PERIODIC
            ,ROUND(SUM(TRANSMITTED_PACKETS_PERIODIC),2)   TRANSMITTED_PACKETS_PERIODIC
            ,ROUND(SUM(RECEIVED_OCTETS_PERIODIC),2)       RECEIVED_OCTETS_PERIODIC
            ,ROUND(SUM(TRANSMITTED_OCTETS_PERIODIC),2)    TRANSMITTED_OCTETS_PERIODIC
            ,ROUND(SUM(RECEIVED_NON_UNI_PACK_PERIODIC),2) RECEIVED_NON_UNI_PACK_PERIODIC
            ,ROUND(SUM(TRANS_NON_UNI_PACK_PERIODIC),2)    TRANS_NON_UNI_PACK_PERIODIC
            ,ROUND(SUM(RECEIVED_BAD_PACKETS_PERIODIC),2)  RECEIVED_BAD_PACKETS_PERIODIC
            ,ROUND(SUM(TRANS_BAD_PACKETS_PERIODIC),2)     TRANS_BAD_PACKETS_PERIODIC
            ,ROUND(MAX(INPUT_SPEED),2)                    INPUT_SPEED
            ,ROUND(MAX(OUTPUT_SPEED),2)                   OUTPUT_SPEED
            ,ROUND(AVG(IN_BANDWITH_UTIL),3)               IN_BANDWITH_UTIL
            ,ROUND(AVG(OUT_BANDWITH_UTIL),3)              OUT_BANDWITH_UTIL
            ,ROUND(SUM(REC_OCTETS),2)                     REC_OCTETS
            ,ROUND(SUM(TRANS_OCTETS),2)                   TRANS_OCTETS
    FROM  ALC_STATS_IPRAN_HOUR
    WHERE TRUNC(FECHA) BETWEEN TO_DATE(DIA,'DDMMYYYY') AND TO_DATE(DIA,'DDMMYYYY') + 86399/86400
    GROUP BY  TRUNC(FECHA)
              ,MONITORED_OBJECT_POINTER
              ,MONITORED_OBJECT_SITEID
              ,MONITORED_OBJECT_SITE_NAME;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_STATS_IPRAN_DAY IS TABLE OF ALC_STATS_IPRAN_DAY%ROWTYPE;
    V_ALC_STATS_IPRAN_DAY TY_ALC_STATS_IPRAN_DAY;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_STATS_IPRAN_DAY LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_STATS_IPRAN_DAY.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_IPRAN_DAY VALUES V_ALC_STATS_IPRAN_DAY(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_DAY',L_ERRNO,L_MSG,
                                                'FECHA -->'                           ||V_ALC_STATS_IPRAN_DAY(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_POINTER -->'        ||V_ALC_STATS_IPRAN_DAY(L_IDX).MONITORED_OBJECT_POINTER||' '||                                                
                                                'MONITORED_OBJECT_SITEID -->'         ||V_ALC_STATS_IPRAN_DAY(L_IDX).MONITORED_OBJECT_SITEID||' '||
                                                'MONITORED_OBJECT_SITE_NAME -->'      ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).MONITORED_OBJECT_SITE_NAME)||' '||
                                                'DROP_EVENTS_PERIODIC -->'            ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).DROP_EVENTS_PERIODIC)||' '||
                                                'DROPPED_FRAMES_PERIODIC -->'         ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).DROPPED_FRAMES_PERIODIC)||' '||
                                                'TRANSMITTED_PACKETS_PERIODIC -->'    ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).TRANSMITTED_PACKETS_PERIODIC)||' '||
                                                'RECEIVED_OCTETS_PERIODIC -->'        ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).RECEIVED_OCTETS_PERIODIC)||' '||
                                                'TRANSMITTED_OCTETS_PERIODIC -->'     ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).TRANSMITTED_OCTETS_PERIODIC)||' '||
                                                'RECEIVED_NON_UNI_PACK_PERIODIC -->'  ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).RECEIVED_NON_UNI_PACK_PERIODIC)||' '||
                                                'TRANS_NON_UNI_PACK_PERIODIC -->'     ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).TRANS_NON_UNI_PACK_PERIODIC)||' '||
                                                'RECEIVED_BAD_PACKETS_PERIODIC -->'   ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).RECEIVED_BAD_PACKETS_PERIODIC)||' '||
                                                'TRANS_BAD_PACKETS_PERIODIC -->'      ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).TRANS_BAD_PACKETS_PERIODIC)||' '||
                                                'INPUT_SPEED -->'                     ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).INPUT_SPEED)||' '||
                                                'OUTPUT_SPEED -->'                    ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).OUTPUT_SPEED)||' '||
                                                'IN_BANDWITH_UTIL -->'                ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).IN_BANDWITH_UTIL)||' '||
                                                'OUT_BANDWITH_UTIL -->'               ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).OUT_BANDWITH_UTIL)||' '||
                                                'REC_OCTETS -->'                      ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).REC_OCTETS)||' '||
                                                'TRANS_OCTETS -->'                    ||TO_CHAR(V_ALC_STATS_IPRAN_DAY(L_IDX).TRANS_OCTETS));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_DAY',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_IPRAN_DAY;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_IPRAN_BH(P_FECHA IN VARCHAR2) AS
    CURSOR  DATOS(DIA VARCHAR2) IS
    SELECT   FECHA
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
            ,TRANS_OCTETS
    FROM  (SELECT   FECHA
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
                    ,TRANS_OCTETS
                    ,ROW_NUMBER() OVER(PARTITION BY TRUNC(FECHA)
                                                    ,MONITORED_OBJECT_POINTER
                                                    ,MONITORED_OBJECT_SITEID
                                                    ,MONITORED_OBJECT_SITE_NAME
                                        ORDER BY  TRANS_OCTETS  DESC) RN
            FROM  ALC_STATS_IPRAN_HOUR
            WHERE TRUNC(FECHA) BETWEEN  TO_DATE(DIA,'DDMMYYYY') AND 
                                        TO_DATE(DIA,'DDMMYYYY') + 86399/86400)
    WHERE RN = 1;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_STATS_IPRAN_BH IS TABLE OF ALC_STATS_IPRAN_BH%ROWTYPE;
    V_ALC_STATS_IPRAN_BH TY_ALC_STATS_IPRAN_BH;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_STATS_IPRAN_BH LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_STATS_IPRAN_BH.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_IPRAN_BH VALUES V_ALC_STATS_IPRAN_BH(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_BH',L_ERRNO,L_MSG,
                                                'FECHA -->'                           ||V_ALC_STATS_IPRAN_BH(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_POINTER -->'        ||V_ALC_STATS_IPRAN_BH(L_IDX).MONITORED_OBJECT_POINTER||' '||                                                
                                                'MONITORED_OBJECT_SITEID -->'         ||V_ALC_STATS_IPRAN_BH(L_IDX).MONITORED_OBJECT_SITEID||' '||
                                                'MONITORED_OBJECT_SITE_NAME -->'      ||V_ALC_STATS_IPRAN_BH(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'DROP_EVENTS_PERIODIC -->'            ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).DROP_EVENTS_PERIODIC)||' '||
                                                'DROPPED_FRAMES_PERIODIC -->'         ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).DROPPED_FRAMES_PERIODIC)||' '||
                                                'TRANSMITTED_PACKETS_PERIODIC -->'    ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).TRANSMITTED_PACKETS_PERIODIC)||' '||
                                                'RECEIVED_OCTETS_PERIODIC -->'        ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).RECEIVED_OCTETS_PERIODIC)||' '||
                                                'TRANSMITTED_OCTETS_PERIODIC -->'     ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).TRANSMITTED_OCTETS_PERIODIC)||' '||
                                                'RECEIVED_NON_UNI_PACK_PERIODIC -->'  ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).RECEIVED_NON_UNI_PACK_PERIODIC)||' '||
                                                'TRANS_NON_UNI_PACK_PERIODIC -->'     ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).TRANS_NON_UNI_PACK_PERIODIC)||' '||
                                                'RECEIVED_BAD_PACKETS_PERIODIC -->'   ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).RECEIVED_BAD_PACKETS_PERIODIC)||' '||
                                                'TRANS_BAD_PACKETS_PERIODIC -->'      ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).TRANS_BAD_PACKETS_PERIODIC)||' '||
                                                'INPUT_SPEED -->'                     ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).INPUT_SPEED)||' '||
                                                'OUTPUT_SPEED -->'                    ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).OUTPUT_SPEED)||' '||
                                                'IN_BANDWITH_UTIL -->'                ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).IN_BANDWITH_UTIL)||' '||
                                                'OUT_BANDWITH_UTIL -->'               ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).OUT_BANDWITH_UTIL)||' '||
                                                'REC_OCTETS -->'                      ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).REC_OCTETS)||' '||
                                                'TRANS_OCTETS -->'                    ||TO_CHAR(V_ALC_STATS_IPRAN_BH(L_IDX).TRANS_OCTETS));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_BH',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_IPRAN_BH;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_IPRAN_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2)  AS
  --
    CURSOR  DATOS(DOMINGO VARCHAR2,SABADO VARCHAR2) IS
    SELECT   FECHA
            ,MONITORED_OBJECT_POINTER
            ,MONITORED_OBJECT_SITEID
            ,MONITORED_OBJECT_SITE_NAME
            ,ROUND(SUM(DROP_EVENTS_PERIODIC),2)           DROP_EVENTS_PERIODIC
            ,ROUND(SUM(DROPPED_FRAMES_PERIODIC),2)        DROPPED_FRAMES_PERIODIC
            ,ROUND(SUM(RECEIVED_PACKETS_PERIODIC),2)      RECEIVED_PACKETS_PERIODIC
            ,ROUND(SUM(TRANSMITTED_PACKETS_PERIODIC),2)   TRANSMITTED_PACKETS_PERIODIC
            ,ROUND(SUM(RECEIVED_OCTETS_PERIODIC),2)       RECEIVED_OCTETS_PERIODIC
            ,ROUND(SUM(TRANSMITTED_OCTETS_PERIODIC),2)    TRANSMITTED_OCTETS_PERIODIC
            ,ROUND(SUM(RECEIVED_NON_UNI_PACK_PERIODIC),2) RECEIVED_NON_UNI_PACK_PERIODIC
            ,ROUND(SUM(TRANS_NON_UNI_PACK_PERIODIC),2)    TRANS_NON_UNI_PACK_PERIODIC
            ,ROUND(SUM(RECEIVED_BAD_PACKETS_PERIODIC),2)  RECEIVED_BAD_PACKETS_PERIODIC
            ,ROUND(SUM(TRANS_BAD_PACKETS_PERIODIC),2)     TRANS_BAD_PACKETS_PERIODIC
            ,ROUND(MAX(INPUT_SPEED),2)                    INPUT_SPEED
            ,ROUND(MAX(OUTPUT_SPEED),2)                   OUTPUT_SPEED
            ,ROUND(AVG(IN_BANDWITH_UTIL),3)               IN_BANDWITH_UTIL
            ,ROUND(AVG(OUT_BANDWITH_UTIL),3)              OUT_BANDWITH_UTIL
            ,ROUND(AVG(REC_OCTETS),2)                     REC_OCTETS
            ,ROUND(AVG(TRANS_OCTETS),2)                   TRANS_OCTETS
    FROM  (SELECT   DOMINGO FECHA
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
                    ,TRANS_OCTETS
                    ,ROW_NUMBER() OVER(PARTITION BY TRUNC(FECHA,'DAY')
                                                    ,MONITORED_OBJECT_POINTER
                                                    ,MONITORED_OBJECT_SITEID
                                                    ,MONITORED_OBJECT_SITE_NAME
                                      ORDER BY  TRANS_OCTETS  DESC) RN
            FROM  ALC_STATS_IPRAN_BH
            WHERE TRUNC(FECHA) BETWEEN  TO_DATE(DOMINGO,'DDMMYYYY') AND 
                                        TO_DATE(SABADO,'DDMMYYYY') + 86399/86400)
    WHERE RN <= limit_in
    GROUP BY  FECHA
              ,MONITORED_OBJECT_POINTER
              ,MONITORED_OBJECT_SITEID
              ,MONITORED_OBJECT_SITE_NAME;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_STATS_IPRAN_IBHW IS TABLE OF ALC_STATS_IPRAN_IBHW%ROWTYPE;
    V_ALC_STATS_IPRAN_IBHW TY_ALC_STATS_IPRAN_IBHW;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHA_DOMINGO,P_FECHA_SABADO);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_STATS_IPRAN_IBHW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_STATS_IPRAN_IBHW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_IPRAN_IBHW VALUES V_ALC_STATS_IPRAN_IBHW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_IBHW',L_ERRNO,L_MSG,
                                                'FECHA -->'                           ||V_ALC_STATS_IPRAN_IBHW(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_POINTER -->'        ||V_ALC_STATS_IPRAN_IBHW(L_IDX).MONITORED_OBJECT_POINTER||' '||                                                
                                                'MONITORED_OBJECT_SITEID -->'         ||V_ALC_STATS_IPRAN_IBHW(L_IDX).MONITORED_OBJECT_SITEID||' '||
                                                'MONITORED_OBJECT_SITE_NAME -->'      ||V_ALC_STATS_IPRAN_IBHW(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'DROP_EVENTS_PERIODIC -->'            ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).DROP_EVENTS_PERIODIC)||' '||
                                                'DROPPED_FRAMES_PERIODIC -->'         ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).DROPPED_FRAMES_PERIODIC)||' '||
                                                'TRANSMITTED_PACKETS_PERIODIC -->'    ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).TRANSMITTED_PACKETS_PERIODIC)||' '||
                                                'RECEIVED_OCTETS_PERIODIC -->'        ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).RECEIVED_OCTETS_PERIODIC)||' '||
                                                'TRANSMITTED_OCTETS_PERIODIC -->'     ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).TRANSMITTED_OCTETS_PERIODIC)||' '||
                                                'RECEIVED_NON_UNI_PACK_PERIODIC -->'  ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).RECEIVED_NON_UNI_PACK_PERIODIC)||' '||
                                                'TRANS_NON_UNI_PACK_PERIODIC -->'     ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).TRANS_NON_UNI_PACK_PERIODIC)||' '||
                                                'RECEIVED_BAD_PACKETS_PERIODIC -->'   ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).RECEIVED_BAD_PACKETS_PERIODIC)||' '||
                                                'TRANS_BAD_PACKETS_PERIODIC -->'      ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).TRANS_BAD_PACKETS_PERIODIC)||' '||
                                                'INPUT_SPEED -->'                     ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).INPUT_SPEED)||' '||
                                                'OUTPUT_SPEED -->'                    ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).OUTPUT_SPEED)||' '||
                                                'IN_BANDWITH_UTIL -->'                ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).IN_BANDWITH_UTIL)||' '||
                                                'OUT_BANDWITH_UTIL -->'               ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).OUT_BANDWITH_UTIL)||' '||
                                                'REC_OCTETS -->'                      ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).REC_OCTETS)||' '||
                                                'TRANS_OCTETS -->'                    ||TO_CHAR(V_ALC_STATS_IPRAN_IBHW(L_IDX).TRANS_OCTETS));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_IBHW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_IPRAN_IBHW;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_CPUMEM_HOUR(P_FECHAHORA IN VARCHAR2)  AS
  --
    CURSOR  DATOS(FECHA_HORA VARCHAR2) IS
    SELECT  TO_CHAR(CPU.FECHA,'DD.MM.YYYY HH24')	        FECHA,
            CPU.MONITORED_OBJECT_SITE_ID,
            CPU.MONITORED_OBJECT_SITE_NAME,
            ROUND(AVG(CPU.SYSTEM_CPU_USAGE),2)	          SYSTEM_CPU_USAGE,
            ROUND(AVG(CPU.SYSTEM_CPU_USAGE),2)	          SYSTEM_CPU_USAGE_AVG,
            ROUND(MAX(CPU.SYSTEM_CPU_USAGE),2)	          SYSTEM_CPU_USAGE_MAX,
            ROUND(AVG(MEM.SYSTEM_MEMORY_USAGE),2)	        SYSTEM_MEMORY_USAGE,
            ROUND(AVG(MEM.SMS_SYSTEM_MEMORY_USAGE_MB),2)	SYSTEM_MEMORY_USAGE_AVG_MB,
            ROUND(MAX(MEM.SMS_SYSTEM_MEMORY_USAGE_MB),2)	SYSTEM_MEMORY_USAGE_MAX_MB,
            ROUND(AVG(MEM.SMS_SYSTEM_MEMORY_USAGE_AVG),2)	SYSTEM_MEMORY_USAGE_AVG_PCT,
            ROUND(MAX(MEM.SMS_SYSTEM_MEMORY_USAGE_AVG),2) SYSTEM_MEMORY_USAGE_MAX,
            ROUND(AVG(MEM.AVAILABLE_MEMORY),2)	          AVAILABLE_MEMORY,
            ROUND(AVG(MEM.AVMS_AVAILABLE_MEMORY_MB),2)	  AVAILABLE_MEMORY_AVG_MB,
            ROUND(MAX(MEM.AVMS_AVAILABLE_MEMORY_MB),2)	  AVAILABLE_MEMORY_MAX_MB,
            ROUND(AVG(MEM.AVMS_AVAILABLE_MEMORY_PCT),2)	  AVAILABLE_MEMORY_AVG_PCT,
            ROUND(MAX(MEM.AVMS_AVAILABLE_MEMORY_PCT),2)	  AVAILABLE_MEMORY_MAX_PCT,
            ROUND(AVG(MEM.ALLOCATED_MEMORY),2)	          ALLOCATED_MEMORY,
            ROUND(SUM(MEM.AMS_ALLOCATED_MEMORY_MB),2)     ALLOCATED_MEMORY_MB
    FROM  ALC_SYSTEM_CPU_STATS_IPRAN_RAW CPU,
          ALC_SYSTEM_MEM_STATS_IPRAN_RAW MEM
    WHERE TO_CHAR(CPU.FECHA,'DDMMYYYYHH24')  = FECHA_HORA
    AND   TO_CHAR(CPU.FECHA,'DDMMYYYYHH24')  = TO_CHAR(MEM.FECHA,'DDMMYYYYHH24')
    AND   CPU.MONITORED_OBJECT_SITE_ID          = MEM.MONITORED_OBJECT_SITE_ID
    AND   CPU.MONITORED_OBJECT_SITE_NAME        = MEM.MONITORED_OBJECT_SITE_NAME
    GROUP BY  TO_CHAR(CPU.FECHA,'DD.MM.YYYY HH24'),
              CPU.MONITORED_OBJECT_SITE_ID,
              CPU.MONITORED_OBJECT_SITE_NAME;
  --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_STATS_CPUMEM_IPRAN_HOUR IS TABLE OF ALC_STATS_CPUMEM_HOUR%ROWTYPE;
    V_ALC_STATS_CPUMEM_IPRAN_H TY_ALC_STATS_CPUMEM_IPRAN_HOUR;
    --
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHAHORA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_STATS_CPUMEM_IPRAN_H LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_STATS_CPUMEM_IPRAN_H.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_CPUMEM_HOUR VALUES V_ALC_STATS_CPUMEM_IPRAN_H(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_HOUR',L_ERRNO,L_MSG,
                                                'FECHA -->'                       ||V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'    ||V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).MONITORED_OBJECT_SITE_ID||' '||                                                
                                                'MONITORED_OBJECT_SITE_NAME -->'  ||V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'SYSTEM_CPU_USAGE -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_CPU_USAGE)||' '||
                                                'SYSTEM_CPU_USAGE_AVG -->'        ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_CPU_USAGE_AVG)||' '||
                                                'SYSTEM_CPU_USAGE_MAX -->'        ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_CPU_USAGE_MAX)||' '||
                                                'SYSTEM_MEMORY_USAGE -->'         ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_MEMORY_USAGE)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_MB -->'  ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_MEMORY_USAGE_AVG_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_MB -->'  ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_MEMORY_USAGE_MAX_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_PCT -->' ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_MEMORY_USAGE_AVG_PCT)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_PCT -->' ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).SYSTEM_MEMORY_USAGE_MAX_PCT)||' '||
                                                'AVAILABLE_MEMORY -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).AVAILABLE_MEMORY)||' '||
                                                'AVAILABLE_MEMORY_AVG_MB -->'     ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).AVAILABLE_MEMORY_AVG_MB)||' '||
                                                'AVAILABLE_MEMORY_MAX_MB -->'     ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).AVAILABLE_MEMORY_MAX_MB)||' '||
                                                'AVAILABLE_MEMORY_AVG_PCT -->'    ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).AVAILABLE_MEMORY_AVG_PCT)||' '||
                                                'AVAILABLE_MEMORY_MAX_PCT -->'    ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).AVAILABLE_MEMORY_MAX_PCT)||' '||
                                                'ALLOCATED_MEMORY -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).ALLOCATED_MEMORY)||' '||
                                                'ALLOCATED_MEMORY_MB -->'         ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_H(L_IDX).ALLOCATED_MEMORY_MB));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_HOUR',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_CPUMEM_HOUR;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_CPUMEM_DAY(P_FECHA IN VARCHAR2) AS
    CURSOR  DATOS(DIA VARCHAR2) IS
    SELECT  TRUNC(FECHA) FECHA,
            MONITORED_OBJECT_SITE_ID,
            MONITORED_OBJECT_SITE_NAME,
            ROUND(AVG(SYSTEM_CPU_USAGE),2)	          SYSTEM_CPU_USAGE,
            ROUND(AVG(SYSTEM_CPU_USAGE_AVG),2)	      SYSTEM_CPU_USAGE_AVG,
            ROUND(MAX(SYSTEM_CPU_USAGE_MAX),2)	      SYSTEM_CPU_USAGE_MAX,
            ROUND(AVG(SYSTEM_MEMORY_USAGE),2)	        SYSTEM_MEMORY_USAGE,
            ROUND(AVG(SYSTEM_MEMORY_USAGE_AVG_MB),2)	SYSTEM_MEMORY_USAGE_AVG_MB,
            ROUND(MAX(SYSTEM_MEMORY_USAGE_MAX_MB),2)	SYSTEM_MEMORY_USAGE_MAX_MB,
            ROUND(AVG(SYSTEM_MEMORY_USAGE_AVG_PCT),2)	SYSTEM_MEMORY_USAGE_AVG_PCT,
            ROUND(MAX(SYSTEM_MEMORY_USAGE_MAX_PCT),2) SYSTEM_MEMORY_USAGE_MAX_PCT,
            ROUND(AVG(AVAILABLE_MEMORY),2)	          AVAILABLE_MEMORY,
            ROUND(AVG(AVAILABLE_MEMORY_AVG_MB),2)	    AVAILABLE_MEMORY_AVG_MB,
            ROUND(MAX(AVAILABLE_MEMORY_MAX_MB),2)	    AVAILABLE_MEMORY_MAX_MB,
            ROUND(AVG(AVAILABLE_MEMORY_AVG_PCT),2)	  AVAILABLE_MEMORY_AVG_PCT,
            ROUND(MAX(AVAILABLE_MEMORY_MAX_PCT),2)	  AVAILABLE_MEMORY_MAX_PCT,
            ROUND(AVG(ALLOCATED_MEMORY),2)	          ALLOCATED_MEMORY,
            ROUND(SUM(ALLOCATED_MEMORY_MB),2)         ALLOCATED_MEMORY_MB
    FROM  ALC_STATS_CPUMEM_HOUR
    WHERE TRUNC(FECHA) BETWEEN TO_DATE(DIA,'DDMMYYYY') AND TO_DATE(DIA,'DDMMYYYY') + 86399/86400
    GROUP BY  TRUNC(FECHA),
              MONITORED_OBJECT_SITE_ID,
              MONITORED_OBJECT_SITE_NAME;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_STATS_CPUMEM_IPRAN_DAY IS TABLE OF ALC_STATS_CPUMEM_DAY%ROWTYPE;
    V_ALC_STATS_CPUMEM_IPRAN_D TY_ALC_STATS_CPUMEM_IPRAN_DAY;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_STATS_CPUMEM_IPRAN_D LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_STATS_CPUMEM_IPRAN_D.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_CPUMEM_DAY VALUES V_ALC_STATS_CPUMEM_IPRAN_D(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_DAY',L_ERRNO,L_MSG,
                                                'FECHA -->'                       ||V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'    ||V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).MONITORED_OBJECT_SITE_ID||' '||                                                
                                                'MONITORED_OBJECT_SITE_NAME -->'  ||V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'SYSTEM_CPU_USAGE -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_CPU_USAGE)||' '||
                                                'SYSTEM_CPU_USAGE_AVG -->'        ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_CPU_USAGE_AVG)||' '||
                                                'SYSTEM_CPU_USAGE_MAX -->'        ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_CPU_USAGE_MAX)||' '||
                                                'SYSTEM_MEMORY_USAGE -->'         ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_MEMORY_USAGE)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_MB -->'  ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_MEMORY_USAGE_AVG_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_MB -->'  ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_MEMORY_USAGE_MAX_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_PCT -->' ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_MEMORY_USAGE_AVG_PCT)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_PCT -->' ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).SYSTEM_MEMORY_USAGE_MAX_PCT)||' '||
                                                'AVAILABLE_MEMORY -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).AVAILABLE_MEMORY)||' '||
                                                'AVAILABLE_MEMORY_AVG_MB -->'     ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).AVAILABLE_MEMORY_AVG_MB)||' '||
                                                'AVAILABLE_MEMORY_MAX_MB -->'     ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).AVAILABLE_MEMORY_MAX_MB)||' '||
                                                'AVAILABLE_MEMORY_AVG_PCT -->'    ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).AVAILABLE_MEMORY_AVG_PCT)||' '||
                                                'AVAILABLE_MEMORY_MAX_PCT -->'    ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).AVAILABLE_MEMORY_MAX_PCT)||' '||
                                                'ALLOCATED_MEMORY -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).ALLOCATED_MEMORY)||' '||
                                                'ALLOCATED_MEMORY_MB -->'         ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_D(L_IDX).ALLOCATED_MEMORY_MB));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_DAY',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_CPUMEM_DAY;
  --**--**--**--**--
  PROCEDURE INS_ALC_STATS_CPUMEM_BH(P_FECHA IN VARCHAR2)  AS
    CURSOR  DATOS(DIA VARCHAR2) IS
    SELECT  FECHA,
            MONITORED_OBJECT_SITE_ID,
            MONITORED_OBJECT_SITE_NAME,
            SYSTEM_CPU_USAGE,
            SYSTEM_CPU_USAGE_AVG,
            SYSTEM_CPU_USAGE_MAX,
            SYSTEM_MEMORY_USAGE,
            SYSTEM_MEMORY_USAGE_AVG_MB,
            SYSTEM_MEMORY_USAGE_MAX_MB,
            SYSTEM_MEMORY_USAGE_AVG_PCT,
            SYSTEM_MEMORY_USAGE_MAX_PCT,
            AVAILABLE_MEMORY,
            AVAILABLE_MEMORY_AVG_MB,
            AVAILABLE_MEMORY_MAX_MB,
            AVAILABLE_MEMORY_AVG_PCT,
            AVAILABLE_MEMORY_MAX_PCT,
            ALLOCATED_MEMORY,
            ALLOCATED_MEMORY_MB
    FROM  (SELECT FECHA,
                  MONITORED_OBJECT_SITE_ID,
                  MONITORED_OBJECT_SITE_NAME,
                  SYSTEM_CPU_USAGE,
                  SYSTEM_CPU_USAGE_AVG,
                  SYSTEM_CPU_USAGE_MAX,
                  SYSTEM_MEMORY_USAGE,
                  SYSTEM_MEMORY_USAGE_AVG_MB,
                  SYSTEM_MEMORY_USAGE_MAX_MB,
                  SYSTEM_MEMORY_USAGE_AVG_PCT,
                  SYSTEM_MEMORY_USAGE_MAX_PCT,
                  AVAILABLE_MEMORY,
                  AVAILABLE_MEMORY_AVG_MB,
                  AVAILABLE_MEMORY_MAX_MB,
                  AVAILABLE_MEMORY_AVG_PCT,
                  AVAILABLE_MEMORY_MAX_PCT,
                  ALLOCATED_MEMORY,
                  ALLOCATED_MEMORY_MB,
                  ROW_NUMBER() OVER (PARTITION BY  TRUNC(FECHA),
                                                  MONITORED_OBJECT_SITE_ID,
                                                  MONITORED_OBJECT_SITE_NAME
                                    ORDER BY  SYSTEM_CPU_USAGE DESC) RN
          FROM  ALC_STATS_CPUMEM_HOUR
          WHERE TRUNC(FECHA) BETWEEN TO_DATE(DIA,'DDMMYYYY') AND TO_DATE(DIA,'DDMMYYYY') + 86399/86400
        )
    WHERE RN = 1;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_STATS_CPUMEM_IPRAN_BH IS TABLE OF ALC_STATS_CPUMEM_BH%ROWTYPE;
    V_ALC_STATS_CPUMEM_IPRAN_BH TY_ALC_STATS_CPUMEM_IPRAN_BH;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHA);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_STATS_CPUMEM_IPRAN_BH LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_STATS_CPUMEM_IPRAN_BH.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_CPUMEM_BH VALUES V_ALC_STATS_CPUMEM_IPRAN_BH(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_BH',L_ERRNO,L_MSG,
                                                'FECHA -->'                       ||V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'    ||V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).MONITORED_OBJECT_SITE_ID||' '||                                                
                                                'MONITORED_OBJECT_SITE_NAME -->'  ||V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'SYSTEM_CPU_USAGE -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_CPU_USAGE)||' '||
                                                'SYSTEM_CPU_USAGE_AVG -->'        ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_CPU_USAGE_AVG)||' '||
                                                'SYSTEM_CPU_USAGE_MAX -->'        ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_CPU_USAGE_MAX)||' '||
                                                'SYSTEM_MEMORY_USAGE -->'         ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_MEMORY_USAGE)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_MB -->'  ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_MEMORY_USAGE_AVG_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_MB -->'  ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_MEMORY_USAGE_MAX_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_PCT -->' ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_MEMORY_USAGE_AVG_PCT)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_PCT -->' ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).SYSTEM_MEMORY_USAGE_MAX_PCT)||' '||
                                                'AVAILABLE_MEMORY -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).AVAILABLE_MEMORY)||' '||
                                                'AVAILABLE_MEMORY_AVG_MB -->'     ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).AVAILABLE_MEMORY_AVG_MB)||' '||
                                                'AVAILABLE_MEMORY_MAX_MB -->'     ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).AVAILABLE_MEMORY_MAX_MB)||' '||
                                                'AVAILABLE_MEMORY_AVG_PCT -->'    ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).AVAILABLE_MEMORY_AVG_PCT)||' '||
                                                'AVAILABLE_MEMORY_MAX_PCT -->'    ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).AVAILABLE_MEMORY_MAX_PCT)||' '||
                                                'ALLOCATED_MEMORY -->'            ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).ALLOCATED_MEMORY)||' '||
                                                'ALLOCATED_MEMORY_MB -->'         ||TO_CHAR(V_ALC_STATS_CPUMEM_IPRAN_BH(L_IDX).ALLOCATED_MEMORY_MB));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_BH',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_CPUMEM_BH;
  --**--**--**--
  PROCEDURE INS_ALC_STATS_CPUMEM_IBHW(P_FECHA_DOMINGO IN VARCHAR2,P_FECHA_SABADO IN VARCHAR2)  AS
    --
    CURSOR  DATOS(DOMINGO VARCHAR2,SABADO VARCHAR2) IS
    SELECT  FECHA,
            MONITORED_OBJECT_SITE_ID,
            MONITORED_OBJECT_SITE_NAME,
            ROUND(AVG(SYSTEM_CPU_USAGE),2)	          SYSTEM_CPU_USAGE,
            ROUND(AVG(SYSTEM_CPU_USAGE_AVG),2)	      SYSTEM_CPU_USAGE_AVG,
            ROUND(MAX(SYSTEM_CPU_USAGE_MAX),2)	      SYSTEM_CPU_USAGE_MAX,
            ROUND(AVG(SYSTEM_MEMORY_USAGE),2)	        SYSTEM_MEMORY_USAGE,
            ROUND(AVG(SYSTEM_MEMORY_USAGE_AVG_MB),2)	SYSTEM_MEMORY_USAGE_AVG_MB,
            ROUND(MAX(SYSTEM_MEMORY_USAGE_MAX_MB),2)	SYSTEM_MEMORY_USAGE_MAX_MB,
            ROUND(AVG(SYSTEM_MEMORY_USAGE_AVG_PCT),2)	SYSTEM_MEMORY_USAGE_AVG_PCT,
            ROUND(MAX(SYSTEM_MEMORY_USAGE_MAX_PCT),2) SYSTEM_MEMORY_USAGE_MAX_PCT,
            ROUND(AVG(AVAILABLE_MEMORY),2)	          AVAILABLE_MEMORY,
            ROUND(AVG(AVAILABLE_MEMORY_AVG_MB),2)	    AVAILABLE_MEMORY_AVG_MB,
            ROUND(MAX(AVAILABLE_MEMORY_MAX_MB),2)	    AVAILABLE_MEMORY_MAX_MB,
            ROUND(AVG(AVAILABLE_MEMORY_AVG_PCT),2)	  AVAILABLE_MEMORY_AVG_PCT,
            ROUND(MAX(AVAILABLE_MEMORY_MAX_PCT),2)	  AVAILABLE_MEMORY_MAX_PCT,
            ROUND(AVG(ALLOCATED_MEMORY),2)	          ALLOCATED_MEMORY,
            ROUND(SUM(ALLOCATED_MEMORY_MB),2)         ALLOCATED_MEMORY_MB
    FROM  (SELECT DOMINGO  FECHA,
                  MONITORED_OBJECT_SITE_ID,
                  MONITORED_OBJECT_SITE_NAME,
                  SYSTEM_CPU_USAGE,
                  SYSTEM_CPU_USAGE_AVG,
                  SYSTEM_CPU_USAGE_MAX,
                  SYSTEM_MEMORY_USAGE,
                  SYSTEM_MEMORY_USAGE_AVG_MB,
                  SYSTEM_MEMORY_USAGE_MAX_MB,
                  SYSTEM_MEMORY_USAGE_AVG_PCT,
                  SYSTEM_MEMORY_USAGE_MAX_PCT,
                  AVAILABLE_MEMORY,
                  AVAILABLE_MEMORY_AVG_MB,
                  AVAILABLE_MEMORY_MAX_MB,
                  AVAILABLE_MEMORY_AVG_PCT,
                  AVAILABLE_MEMORY_MAX_PCT,
                  ALLOCATED_MEMORY,
                  ALLOCATED_MEMORY_MB,
                  ROW_NUMBER() OVER (PARTITION BY MONITORED_OBJECT_SITE_ID,
                                                  MONITORED_OBJECT_SITE_NAME
                                    ORDER BY  SYSTEM_CPU_USAGE DESC) RN
          FROM  ALC_STATS_CPUMEM_HOUR
          WHERE TRUNC(FECHA) BETWEEN TO_DATE(DOMINGO,'DDMMYYYY') AND TO_DATE(SABADO,'DDMMYYYY') + 86399/86400
        )
    WHERE RN <= limit_in
    GROUP BY  FECHA,
              MONITORED_OBJECT_SITE_ID,
              MONITORED_OBJECT_SITE_NAME;
    --
    L_ERRORS NUMBER;
    L_ERRNO  NUMBER;
    L_MSG    VARCHAR2(4000);
    L_IDX    NUMBER;
    -- END LOG --
    TYPE TY_ALC_S_CM_IPRAN_IBHW IS TABLE OF ALC_STATS_CPUMEM_IBHW%ROWTYPE;
    V_ALC_S_CM_IPRAN_IBHW TY_ALC_S_CM_IPRAN_IBHW;
  BEGIN
    EXECUTE IMMEDIATE 'alter session set nls_date_format = ''DD.MM.YYYY HH24:MI:SS''';
    --
    OPEN DATOS(P_FECHA_DOMINGO,P_FECHA_SABADO);
    LOOP
      FETCH DATOS BULK COLLECT INTO V_ALC_S_CM_IPRAN_IBHW LIMIT bulk_limit;
      BEGIN
        FORALL fila IN 1 .. V_ALC_S_CM_IPRAN_IBHW.COUNT SAVE EXCEPTIONS
          INSERT INTO ALC_STATS_CPUMEM_IBHW VALUES V_ALC_S_CM_IPRAN_IBHW(fila);
          
        EXCEPTION
            WHEN OTHERS THEN
              -- Capture exceptions to perform operations DML
              l_errors := sql%bulk_exceptions.count;
              for i in 1 .. l_errors
              loop
                  l_errno := sql%bulk_exceptions(i).error_code;
                  l_msg   := sqlerrm(-l_errno);
                  L_IDX   := sql%BULK_EXCEPTIONS(I).ERROR_INDEX;

                  G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_IBHW',L_ERRNO,L_MSG,
                                                'FECHA -->'                       ||V_ALC_S_CM_IPRAN_IBHW(L_IDX).FECHA||' '||
                                                'MONITORED_OBJECT_SITE_ID -->'    ||V_ALC_S_CM_IPRAN_IBHW(L_IDX).MONITORED_OBJECT_SITE_ID||' '||                                                
                                                'MONITORED_OBJECT_SITE_NAME -->'  ||V_ALC_S_CM_IPRAN_IBHW(L_IDX).MONITORED_OBJECT_SITE_NAME||' '||
                                                'SYSTEM_CPU_USAGE -->'            ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_CPU_USAGE)||' '||
                                                'SYSTEM_CPU_USAGE_AVG -->'        ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_CPU_USAGE_AVG)||' '||
                                                'SYSTEM_CPU_USAGE_MAX -->'        ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_CPU_USAGE_MAX)||' '||
                                                'SYSTEM_MEMORY_USAGE -->'         ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_MEMORY_USAGE)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_MB -->'  ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_MEMORY_USAGE_AVG_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_MB -->'  ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_MEMORY_USAGE_MAX_MB)||' '||
                                                'SYSTEM_MEMORY_USAGE_AVG_PCT -->' ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_MEMORY_USAGE_AVG_PCT)||' '||
                                                'SYSTEM_MEMORY_USAGE_MAX_PCT -->' ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).SYSTEM_MEMORY_USAGE_MAX_PCT)||' '||
                                                'AVAILABLE_MEMORY -->'            ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).AVAILABLE_MEMORY)||' '||
                                                'AVAILABLE_MEMORY_AVG_MB -->'     ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).AVAILABLE_MEMORY_AVG_MB)||' '||
                                                'AVAILABLE_MEMORY_MAX_MB -->'     ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).AVAILABLE_MEMORY_MAX_MB)||' '||
                                                'AVAILABLE_MEMORY_AVG_PCT -->'    ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).AVAILABLE_MEMORY_AVG_PCT)||' '||
                                                'AVAILABLE_MEMORY_MAX_PCT -->'    ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).AVAILABLE_MEMORY_MAX_PCT)||' '||
                                                'ALLOCATED_MEMORY -->'            ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).ALLOCATED_MEMORY)||' '||
                                                'ALLOCATED_MEMORY_MB -->'         ||TO_CHAR(V_ALC_S_CM_IPRAN_IBHW(L_IDX).ALLOCATED_MEMORY_MB));
              end loop;
          -- end --
      END;
      EXIT WHEN DATOS%NOTFOUND;
    END LOOP;
    COMMIT;
    CLOSE DATOS;
    EXCEPTION
    WHEN OTHERS THEN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_IBHW',SQLCODE,SQLERRM,DBMS_UTILITY.format_error_backtrace );
      
  END INS_ALC_STATS_CPUMEM_IBHW;
  --**--**--**--
  PROCEDURE ALC_CALC_SUM_DAY_BH_IBHW(P_FECHA IN  VARCHAR2)  AS
    V_DIA     VARCHAR2(10 CHAR) := '';
    V_DOMINGO VARCHAR2(10 CHAR) := '';
    V_SABADO  VARCHAR2(10 CHAR) := '';
    V_AYER    VARCHAR2(10 CHAR) := '';
  BEGIN
    -- Calculo la fecha del dia anterior a P_FECHA para el calculo de DAY, BH
    SELECT  TO_CHAR(TO_DATE(P_FECHA,'DDMMYYYY')-1,'DDMMYYYY')  
    INTO    V_AYER
    FROM    DUAL;
    -- STATS_IPRAN
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY ALC_STATS_IPRAN_DAY('||V_AYER||')');
    INS_ALC_STATS_IPRAN_DAY(V_AYER);
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_DAY',0,'NO ERROR','COMIENZO CALCULO BH ALC_STATS_IPRAN_BH('||V_AYER||')');
    INS_ALC_STATS_IPRAN_BH(V_AYER);
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_DAY',0,'NO ERROR','FIN CALCULO BH');
    --
    -- STATS_CPUMEN
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_DAY',0,'NO ERROR','COMIENZO DE SUMARIZACION DAY ALC_STATS_CPUMEM_DAY('||V_AYER||')');
    INS_ALC_STATS_CPUMEM_DAY(V_AYER);
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_DAY',0,'NO ERROR','FIN DE SUMARIZACION DAY');
    --
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_BH',0,'NO ERROR','COMIENZO CALCULO BH ALC_STATS_CPUMEM_BH('||V_AYER||')');
    INS_ALC_STATS_CPUMEM_BH(V_AYER);
    G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_BH',0,'NO ERROR','FIN CALCULO BH');
    --
    -- Si el dia actual es DOMINGO, entonces calcular sumarizacion IBHW de la semana anterior,
    -- siempre de domingo a sabado
    --
    SELECT TO_CHAR(TO_DATE(P_FECHA,'DDMMYYYY'),'DAY')
    INTO V_DIA
    FROM DUAL;
    --
    V_DOMINGO := TO_CHAR(TO_DATE(P_FECHA,'DDMMYYYY')-7,'DDMMYYYY');
    V_SABADO  := TO_CHAR(TO_DATE(P_FECHA,'DDMMYYYY')-1,'DDMMYYYY');
    --
    IF (TRIM(V_DIA) = 'SUNDAY') OR (TRIM(V_DIA) = 'DOMINGO') THEN
      -- STATS_IPRAN
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  V_DOMINGO||' P_FECHA_SABADO => '||V_SABADO);
      --
      INS_ALC_STATS_IPRAN_IBHW(V_DOMINGO,V_SABADO);
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_IPRAN_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
      --
      -- STATS_CPUMEM
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_IBHW',0,'NO ERROR','COMIENZO DE SUMARIZACION IBHW P_FECHA_DOMINGO => '||
                                  V_DOMINGO||' P_FECHA_SABADO => '||V_SABADO);
      --
      INS_ALC_STATS_CPUMEM_IBHW(V_DOMINGO,V_SABADO);
      --
      G_ERROR_LOG_NEW.P_LOG_ERROR('INS_ALC_STATS_CPUMEM_IBHW',0,'NO ERROR','FIN DE SUMARIZACION IBHW');
    END IF;
  END ALC_CALC_SUM_DAY_BH_IBHW;
  --**--**--**--
END G_ALC_IPRAN;