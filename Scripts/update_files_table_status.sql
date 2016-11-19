MERGE INTO FILES
USING (SELECT  TBL.NOMBRE_CSV ARCHIVO,
               TBL.CNT_LOADED - FLS.CNT_FILAS TOTAL
      FROM  (SELECT NOMBRE_CSV,COUNT(*) CNT_LOADED
            FROM  XML_MEDIA_INDEPEND_STATS --${TABLA}
            WHERE NOMBRE_CSV LIKE '%20161118%'
            GROUP BY NOMBRE_CSV) TBL,
            (SELECT  NOMBRE_CSV,(row_num -1) CNT_FILAS
            FROM FILES
            WHERE REGEXP_LIKE(NOMBRE_CSV,'^*(mediaIndependStats_xml).csv$') --
            --AND NOT REGEXP_LIKE(nombre_csv,'^*(CardStatus_xml_1)\.csv$')
            AND NOMBRE_CSV LIKE '%20161118%' --Formato YYYYMMDD
            --AND STATUS = 5
            --AND PROCESADO IS NULL
            ) FLS
      WHERE TBL.NOMBRE_CSV = FLS.NOMBRE_CSV) PARES
ON (FILES.NOMBRE_CSV = PARES.ARCHIVO)
WHEN MATCHED THEN
  UPDATE SET
    STATUS = CASE
                WHEN  PARES.TOTAL = 0 THEN 0 ELSE 1
            END,
    PROCESADO = SYSDATE;

set verify off
define nombre_csv='/home/oracle/NokiaAluIPRAN/xml_output/201611181107_mediaIndependStats_xml.csv'
select
SUBSTR('&nombre_csv',instr('&nombre_csv','_',2)+8,12)
from dual;

SELECT  NOMBRE_CSV,sum(row_num -1) CNT_FILAS
FROM FILES
WHERE REGEXP_LIKE(NOMBRE_CSV,'^*(mediaIndependStats_xml).csv$') --
--AND NOT REGEXP_LIKE(nombre_csv,'^*(CardStatus_xml_1)\.csv$')
AND NOMBRE_CSV LIKE '%20161118%' --Formato YYYYMMDD
AND STATUS = 5
AND PROCESADO IS NULL
            
            
            
            
            
            
            