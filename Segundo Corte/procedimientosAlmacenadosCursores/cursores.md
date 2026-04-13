# Cursores 
Un cursor es una estructura en SQL que permíte recorrer registros uno por uno, yendo fila por fila. Se puede decir que este es el "for" de SQL.
Las partes de un cursor:
  1.  Declarar cursor
  2.  Abrir cursor
  3.  Leer datos
  4.  Cerrar cursor
La sintaxis general es:
DECLARE nombre_cursor CURSOR FOR:
  SELECT columnas FROM tabla;
  OPEN nombre_cursor;
  FETCH nombre_cursor INTO variables;
CLOSE nombre_cursor;

DELIMITER $$
CREATE PROCEDURE recorrer_clientes()
BEGIN 
  DECLARE done INT DEFAULT 0;
  DECLARE nombre VARCHAR(100);

  DECLARE cursor_clientes CURSOR FOR
    SELECT nombreCliente FROM clientes;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1; #cuando no haya más filas para leer, pon la variable done en 1 y sigue el flujo sin error

  OPEN cursor_clientes;
  read_loop: LOOP
    FETCH cursor_clientes INTO nombre; #FETCH toma una fila del cursor y la guarda en variables
    IF done THEN
      LEAVE read_loop;
    END IF;
  END LOOP;
  CLOSE cursor_clientes;
END $$
DELIMITER ;

Ejecutar cursor: CALL recorrer_clientes();

