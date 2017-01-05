-- drop table ALC_IPRAN_LINKS purge;

CREATE TABLE ALC_IPRAN_LINKS (
  ELEMENT_ID        NUMBER NOT NULL ENABLE, 
  ELEMENT_ALIASES   VARCHAR2(500 CHAR), 
  VALID_START_DATE  DATE, 
  VALID_FINISH_DATE DATE, 
  TIPO              VARCHAR2(40 CHAR), 
  ORIGEN            VARCHAR2(40 CHAR), 
  DESTINO           VARCHAR2(40 CHAR), 
  FLAG_ENABLED      CHAR(1 CHAR), 
  GRUPO             VARCHAR2(50 CHAR), 
  PAIS              VARCHAR2(20 CHAR), 
  ELEMENT_TYPE      VARCHAR2(20 CHAR), 
  ELEMENT_NAME      VARCHAR2(20 CHAR), 
  INTERFACE_NAME    VARCHAR2(500 CHAR), 
  GROUP_TYPE        VARCHAR2(20 CHAR), 
  ELEMENT_IP        VARCHAR2(15 CHAR), 
  NOMBRE_GRUPO      VARCHAR2(50 CHAR), 
  FRONTERA          VARCHAR2(30 CHAR), 
  SPEED_MODIFY      NUMBER
 ) NOCOMPRESS NOLOGGING
TABLESPACE DEVELOPER ;


ALTER TABLE ALC_IPRAN_LINKS ADD CONSTRAINT PK_ALC_IPRAN_LINKS PRIMARY KEY (ELEMENT_ID);
---------------------------------------------------------------------------------------
-- SYNONYM
---------------------------------------------------------------------------------------
CREATE PUBLIC SYNONYM ALC_IPRAN_LINKS FOR MCARRASCO.ALC_IPRAN_LINKS;
---------------------------------------------------------------------------------------
-- PRIV.
---------------------------------------------------------------------------------------
GRANT SELECT ON ALC_IPRAN_LINKS TO FRINALDI;
GRANT SELECT ON ALC_IPRAN_LINKS TO MSTUYCK;
---------------------------------------------------------------------------------------
-- TAPI
---------------------------------------------------------------------------------------
-- DROP TYPE ALC_IPRAN_LINKS_TAPI_REC;

CREATE type ALC_IPRAN_LINKS_TAPI_REC AS OBJECT  (
    ELEMENT_ID	      NUMBER,
    ELEMENT_ALIASES	  VARCHAR2(500 CHAR),
    VALID_START_DATE	DATE,
    VALID_FINISH_DATE	DATE,
    TIPO	            VARCHAR2(40 CHAR),
    ORIGEN	          VARCHAR2(40 CHAR),
    DESTINO	          VARCHAR2(40 CHAR),
    FLAG_ENABLED	    CHAR(1 CHAR),
    GRUPO	            VARCHAR2(50 CHAR),
    PAIS	            VARCHAR2(20 CHAR),
    ELEMENT_TYPE	    VARCHAR2(20 CHAR),
    ELEMENT_NAME	    VARCHAR2(20 CHAR),
    INTERFACE_NAME	  VARCHAR2(500 CHAR),
    GROUP_TYPE	      VARCHAR2(20 CHAR),
    ELEMENT_IP	      VARCHAR2(15 CHAR),
    NOMBRE_GRUPO	    VARCHAR2(50 CHAR),
    FRONTERA	        VARCHAR2(30 CHAR),
    SPEED_MODIFY	    NUMBER 
);
    
    
CREATE TYPE ALC_IPRAN_LINKS_tapi_tab IS TABLE OF ALC_IPRAN_LINKS_TAPI_REC;


 -- insert
  PROCEDURE INS_ALC_IPRAN_LINKS(P_DATASET IN ALC_IPRAN_LINKS_TAPI_REC);
--  begin
--    FORALL i IN emp_rec.first..emp_rec.last
--MERGE INTO emp t
--USING dual
--ON ( t.emp_id = emp_rec(i).emp_id 
-- AND t.emp_dept = emp_rec(i).emp_dept )
--WHEN MATCHED THEN
-- UPDATE SET
-- t.col1 = emp_rec(i).col1,
-- t.col2= emp_rec(i).col2,
-- ...
--WHEN NOT MATCHED THEN
-- INSERT (col1, col2, col3, ...)
-- VALUES (emp_rec(i).col1, emp_rec(i).col2, emp_rec(i).col3, ...)
--;
--end;
  -- update
  PROCEDURE UPD_ALC_IPRAN_LINKS(P_DATASET IN ALC_IPRAN_LINKS_TAPI_REC);