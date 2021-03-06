--------------------------------------------------------
--  DDL for Table PROCESS_TO_RUN
--------------------------------------------------------

CREATE TABLE PROCESS_TO_RUN (	
PROCESS_NAME  VARCHAR2(500 CHAR), 
PARAMS        VARCHAR2(500 CHAR), 
FECHA_TO_RUN  VARCHAR2(13 CHAR), 
TIPO          VARCHAR2(50 CHAR), 
GRUPO         VARCHAR2(50 CHAR), 
STATUS        NUMBER(1,0) DEFAULT 1, 
PROCESADO     DATE, 
JOB_NAME      VARCHAR2(500 CHAR) GENERATED ALWAYS AS (SUBSTR(PROCESS_NAME,INSTR(PROCESS_NAME,'/',-1)+1,LENGTH(PROCESS_NAME))) VIRTUAL 
) 
NOCOMPRESS NOLOGGING
TABLESPACE TBS_AUXILIAR ;

COMMENT ON COLUMN PROCESS_TO_RUN.FECHA_TO_RUN IS 'Representa la fecha-hora que se pasara como parametro al Job';
COMMENT ON TABLE PROCESS_TO_RUN  IS 'Contiene todos los procesos PENTAHO (.kjb) que se ejecutaran, funciona como una cola';

--------------------------------------------------------
--  Constraints for Table PROCESS_TO_RUN
--------------------------------------------------------

ALTER TABLE PROCESS_TO_RUN ADD CONSTRAINT CHK_PROCESS_TO_RUN CHECK (tipo in ('Hourly','Daily','Weekly','Monthly')) ENABLE;
ALTER TABLE PROCESS_TO_RUN MODIFY (STATUS NOT NULL ENABLE);
ALTER TABLE PROCESS_TO_RUN MODIFY (FECHA_TO_RUN NOT NULL ENABLE);
ALTER TABLE PROCESS_TO_RUN MODIFY (PROCESS_NAME NOT NULL ENABLE);
ALTER TABLE PROCESS_TO_RUN ADD CONSTRAINT PK_PROCESSTORUN PRIMARY KEY (PROCESS_NAME, FECHA_TO_RUN) ENABLE;
