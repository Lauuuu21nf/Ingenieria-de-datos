## Vista
Una vista es una tabla virtual que esta basada en el resultado de una consulta. En este caso, no se guardan los datos físicamente, sino que solo guarda la consulta.
Se puede decir que una vista es como una consulta guardada con un nombre. La sintaxis básica es la siguiente:
CREATE VIEW nombre_vista AS
  SELECT columnas
  FROM tabla
  WHERE condicion;
Para luego poder usar:
SELECT * FROM nombre_vista;
# Vista Simple
Usa solo una tabla dentro de la consulta y no consta de funciones complejas
CREATE VIEW vista_productos AS
  SELECT nombreProducto, precioProducto
  FROM productos;
# Vista Compleja
Usa varias tablas y puede tener JOINs, funciones, GROUP BY
CREATE VIEW vista_pedidos_detalle AS
  SELECT c.nombreCliente, p.nombreProducto, pe.cantidadProducto
  FROM pedido pe
  JOIN clientes c ON pe.idClienteFK = c.idCliente
  JOIN productos p ON pe.idProductoFK = p.idProducto;
