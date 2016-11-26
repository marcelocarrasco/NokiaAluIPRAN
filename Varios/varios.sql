
set verify off
define fecha='25.11.2016'
delete from XML_MEDIA_INDEPEND_STATS where substr(fecha,1,10) = '&fecha';
delete from XML_MEDIA_INDEPEND_STATS_1 where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS_1 where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS_2 where substr(fecha,1,10) = '&fecha';
delete from XML_SYSTEM_STATS_3 where substr(fecha,1,10) = '&fecha';
delete from XML_NTWQOS where substr(fecha,1,10) = '&fecha';
delete from XML_NTWQOS_1 where substr(fecha,1,10) = '&fecha';
delete from XML_CARD_STATUS where substr(fecha,1,10) = '&fecha';


SELECT  NOMBRE_CSV
FROM (select '201611241622_mediaIndependStats_xml_1.csv' NOMBRE_CSV from dual)
WHERE REGEXP_LIKE(NOMBRE_CSV,'^2016112416(*mediaIndependStats_xml)\.csv$') --
--AND NOT REGEXP_LIKE(nombre_csv,'^*(CardStatus_xml_1)\.csv$')
AND NOMBRE_CSV LIKE '%2016112416%'
--AND SUBSTR(NOMBRE_CSV,-31,8) = '${FECHA-PROC}' --Formato YYYYMMDDHH24
--AND STATUS = 5
--AND PROCESADO IS NULL