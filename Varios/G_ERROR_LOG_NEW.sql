CREATE OR REPLACE PACKAGE G_ERROR_LOG_NEW AS
/**
* Author: Carrasco Marcelo mailto: mcarrasco@harriague.com
* Date: 14/03/2016
* Comment: Paquete para conter la funcionalidad asociada a la tabla error_log_new.
*/

/**
* Date: 14/03/2016
* Comment: Procedimiento para escribir en la tabla ERROR_LOG_NEW.
* Param:  P_OBJETO: Procedimiento o funcion que causo el error.
*         P_SQL_CODE: Número de código de la excepción más reciente.
*         P_SQL_ERRM: Mensaje de error asociado a un número de error.
*         P_COMENTARIO: Comentario asociado al error, usualmente contiene los parámetros de llamada a P_OBJETO.
*/
  procedure P_LOG_ERROR(P_OBJETO in varchar,
                        P_SQL_CODE IN NUMBER,
                        P_SQL_ERRM IN VARCHAR2,
                        P_COMENTARIO IN VARCHAR2);
  /**
  * Comment: Procedimiento para limpiar los datos de la tabla hasta una fecha determinada
  * Param: P_FECHA VARCHAR2 (dd.mm.yyyy) indica la fecha hasta la que se pretende eliminar filas incluida la fecha
  *                                      pasada como parámetro, en caso de no ser especificada, utiliza (sysdate - 1)             
  */                      
  PROCEDURE clean_up (p_fecha IN VARCHAR2 DEFAULT SYSDATE);
end g_error_log_new;
/


CREATE OR REPLACE PACKAGE BODY G_ERROR_LOG_NEW AS
 /**
  * @author: Carrasco Marcelo
  * @date: 14/02/2016
  * @comment: Procedure para insertar las excepciones ocurridas durante la ejecuci?n de procedures y/o fucntions;
  */
  procedure P_LOG_ERROR(P_OBJETO in varchar,
                        P_SQL_CODE in number,
                        P_SQL_ERRM IN VARCHAR2,
                        P_COMENTARIO IN VARCHAR2)as
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO ERROR_LOG_NEW (OBJETO,SQL_CODE,SQL_ERRM,COMENTARIO)
    VALUES (P_OBJETO,P_SQL_CODE,P_SQL_ERRM,P_COMENTARIO);
    commit;
  END P_LOG_ERROR;
  
  PROCEDURE clean_up (p_fecha IN VARCHAR2 DEFAULT SYSDATE) AS
    v_fecha varchar2(10 char) := to_char(sysdate -1,'dd.mm.yyyy');
  BEGIN
    IF P_FECHA IS NOT NULL THEN
      v_fecha := P_FECHA;
    END IF;
    DELETE FROM ERROR_LOG_NEW WHERE to_char(FECHA,'dd.mm.yyyy') <= v_fecha;
    COMMIT;
  end;
end g_error_log_new;
/
