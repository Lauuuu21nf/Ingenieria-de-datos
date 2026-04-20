-- =====================================================
-- DDL: CREACION DE BASE DE DATOS Y TABLAS
-- =====================================================
DROP DATABASE IF EXISTS tienda_tech;
CREATE DATABASE tienda_tech CHARACTER SET utf8mb4;
USE tienda_tech;

CREATE TABLE clientes (
    cliente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    email           VARCHAR(100) UNIQUE NOT NULL,
    ciudad          VARCHAR(60),
    fecha_registro  DATE DEFAULT (CURRENT_DATE)
);

CREATE TABLE productos (
    producto_id  INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    categoria    VARCHAR(60),
    precio       DECIMAL(10,2) NOT NULL CHECK (precio > 0),
    stock        INT DEFAULT 0
);

CREATE TABLE pedidos (
    pedido_id    INT AUTO_INCREMENT PRIMARY KEY,
    cliente_id   INT NOT NULL,
    producto_id  INT NOT NULL,
    cantidad     INT NOT NULL CHECK (cantidad > 0),
    fecha_pedido DATE DEFAULT (CURRENT_DATE),
    estado       VARCHAR(20) DEFAULT "pendiente"
        CHECK (estado IN ("pendiente","entregado","cancelado")),
    FOREIGN KEY (cliente_id)  REFERENCES clientes(cliente_id),
    FOREIGN KEY (producto_id) REFERENCES productos(producto_id)
);

-- =====================================================
-- DML: DATOS DE PRUEBA
-- =====================================================
INSERT INTO clientes VALUES
 (1,"Ana Lopez","ana@mail.com","Bogota","2023-01-15"),
 (2,"Carlos Ruiz","carlos@mail.com","Medellin","2023-03-22"),
 (3,"Maria Torres","maria@mail.com","Cali","2023-05-10"),
 (4,"Pedro Gomez","pedro@mail.com","Bogota","2023-07-08"),
 (5,"Sofia Herrera","sofia@mail.com","Barranquilla","2023-09-01"),
 (6,"Luis Martinez","luis@mail.com","Bogota","2024-01-20"),
 (7,"Camila Vargas","camila@mail.com","Cali","2024-02-14"),
 (8,"Diego Morales","diego@mail.com","Medellin","2024-03-30");

INSERT INTO productos VALUES
 (1,"Laptop Pro 15","Computadores",3500000.00,12),
 (2,"Mouse Inalambrico","Perifericos",85000.00,50),
 (3,"Teclado Mecanico","Perifericos",220000.00,30),
 (4,"Monitor 27","Pantallas",1200000.00,8),
 (5,"Auriculares BT","Audio",350000.00,25),
 (6,"Webcam HD","Perifericos",180000.00,20),
 (7,"Disco SSD 1TB","Almacenamiento",420000.00,40),
 (8,"Tablet 10","Moviles",1800000.00,6);

INSERT INTO pedidos VALUES
 (1,1,1,1,"2024-01-10","entregado"),(2,1,2,2,"2024-01-15","entregado"),
 (3,2,3,1,"2024-02-05","entregado"),(4,2,5,1,"2024-02-20","cancelado"),
 (5,3,4,1,"2024-03-01","entregado"),(6,3,7,2,"2024-03-15","pendiente"),
 (7,4,2,3,"2024-04-02","entregado"),(8,4,6,1,"2024-04-10","pendiente"),
 (9,5,8,1,"2024-04-18","entregado"),(10,6,1,2,"2024-05-05","entregado"),
 (11,6,3,1,"2024-05-12","pendiente"),(12,7,5,2,"2024-05-20","entregado"),
 (13,1,7,1,"2024-06-01","entregado"),(14,8,4,1,"2024-06-10","cancelado"),
 (15,5,2,4,"2024-06-15","entregado"),(16,3,1,1,"2024-07-01","pendiente");
 
 /* 1. Agregue a la tabla pedidos una columna total_valor DECIMAL(12,2) generada automáticamente 
 como la multiplicacion de cantidad por el precio del producto (columna calculada persistida con 
 AS ... STORED, o en su defecto agréguela como columna normal y luego actualice su valor mediante un 
 UPDATE con JOIN entre pedidos y productos). Finalmente, agregue un índice sobre la columna estado.
*/

ALTER TABLE pedidos ADD total_valor DECIMAL(10, 2);
UPDATE pedidos p
INNER JOIN productos pr
SET total_valor = p.cantidad * pr.precio;
SELECT * FROM pedidos;

CREATE INDEX id_estado
ON pedidos(estado);

/* 2. Cree la tabla log_cambios_estado (log_id PK AI, pedido_id FK, estado_anterior VARCHAR(20), 
estado_nuevo VARCHAR(20), fecha_cambio DATETIME DEFAULT NOW()). A continuación, cree una vista llamada 
vista_log_reciente que muestre los últimos 10 registros de log_cambios_estado ordenados por fecha_cambio descendente
*/

CREATE TABLE log_cambios_estado(
log_id INT AUTO_INCREMENT PRIMARY KEY,
pedido_id INT,
FOREIGN KEY (pedido_id) REFERENCES pedidos(pedido_id),
estado_anterior VARCHAR(20),
estado_nuevo VARCHAR(20),
fecha_cambio DATETIME DEFAULT NOW()
);

CREATE VIEW vista_log_reciente AS
	SELECT log_id, pedido_id, estado_anterior, estado_nuevo, fecha_cambio FROM log_cambios_estado
    ORDER BY fecha_cambio desc
    LIMIT 10; -- para ver los más recientes 
    
SELECT * FROM vista_log_reciente;

/* 3. Realice las siguientes operaciones en una misma sesión: (a) Inserte un nuevo cliente 
(nombre=Laura Rios, email=laura@mail.com, ciudad=Manizales). (b) Inserte un pedido para ese 
cliente del producto_id=3 con cantidad=2 y estado=pendiente. (c) Actualice el stock del producto_id=3 
decrementandolo en 2. (d) Consulte con un JOIN el nombre del cliente, nombre del producto y estado del pedido recién creado.
*/

INSERT INTO clientes(nombre, email, ciudad) VALUES ('Laura Rios', 'laura@mail.com', 'Manizales');
SELECT * FROM clientes;
INSERT INTO pedidos(cliente_id, producto_id, cantidad, estado) VALUES (9, 3, 2, 'pendiente');

UPDATE productos
SET stock = stock - 2
WHERE producto_id = 3;

SELECT * FROM productos;

SELECT 
c.nombre AS nombreCliente,
pr.nombre AS nombreProducto,
p.estado AS estadoPedido
FROM pedidos p
INNER JOIN clientes c ON c.cliente_id = p.cliente_id
INNER JOIN productos pr ON pr.producto_id = p.producto_id
WHERE p.cliente_id = 9;

/* 4. Actualice el precio de todos los productos cuyo stock sea menor al promedio de stock 
de su misma categoría (use subconsulta correlacionada), incrementando el precio un 8%. Luego elimine los pedidos 
con estado cancelado cuyos clientes no tengan ningún otro pedido en estado entregado (use subconsulta con NOT EXISTS).
*/

UPDATE productos pr
SET precio = precio*1.08
WHERE stock < 
	(SELECT AVG(pr2.stock)
    FROM productos pr2  -- como es correlacionada, necesitamos dos alias diferentes para la misma tabla
    WHERE pr2.categoria = pr.categoria);
    
DELETE FROM pedidos p
WHERE estado = 'cancelado'
AND NOT EXISTS(
	SELECT *
    FROM (SELECT p2.cliente_id
		FROM pedidos p2
		WHERE p2.estado = 'entregado'
    ) AS entregado
	WHERE entregado.cliente_id = p.cliente_id
);

/* 5. Liste el nombre del cliente, ciudad, nombre del producto, cantidad y fecha_pedido de todos los pedidos entregados 
cuyo total (cantidad * precio) supere el promedio general de totales de pedidos entregados. Ordene los resultados por 
total descendente.
*/

SELECT 
c.nombre AS nombreCliente,
pr.nombre AS nombreProducto,
p.cantidad AS cantidad,
p.fecha_pedido AS fechaPedido,
(p.cantidad * pr.precio) AS total
FROM pedidos p
INNER JOIN clientes c ON c.cliente_id = p.cliente_id
INNER JOIN productos pr ON pr.producto_id = p.producto_id
WHERE p.estado = 'entrega do'
AND (p.cantidad * pr.precio) > 
	(SELECT AVG(p2.cantidad * pr2.precio)
	FROM pedidos p2
    INNER JOIN productos pr2 ON pr2.producto_id = p2.producto_id
    WHERE p2.estado = 'entregado')
ORDER BY total desc;

/* 6. Cree la vista vista_ventas_ciudad que muestre: ciudad, total_pedidos_entregados, 
suma_ingresos (SUM de cantidad*precio) y promedio_ingreso_por_pedido. Luego consulte la vista para mostrar solo 
las ciudades cuyo suma_ingresos supere los 5,000,000, ordenadas de mayor a menor.*/

CREATE VIEW vista_ventas_ciudad AS
	SELECT 
    c.ciudad AS ciudad,
    COUNT(p.pedido_id) AS total_pedidos_entregados,
    SUM(p.cantidad * pr.precio) AS suma_ingresos,
    AVG(p.cantidad * pr.precio) AS promedio_ingreso_por_pedido
    FROM pedidos p
    INNER JOIN clientes c ON c.cliente_id = p.cliente_id
    INNER JOIN productos pr ON pr.producto_id = p.producto_id
    WHERE p.estado = 'entregado'
    GROUP BY c.ciudad;

SELECT * FROM vista_ventas_ciudad
WHERE suma_ingresos > 5000000
ORDER BY suma_ingresos desc; 

/* 7. Cree la vista vista_productos_populares que liste los productos que hayan sido pedidos por más de un 
cliente distinto (en pedidos entregados). La vista debe mostrar: producto_id, nombre, categoria, precio y 
total_clientes_distintos. Luego use la vista para obtener unicamente los productos de la categoría Perifericos.
*/

CREATE VIEW vista_productos_populares AS
SELECT
pr.producto_id,
pr.nombre AS nombreProducto,
pr.categoria AS categoriaProducto,
pr.precio,
COUNT(DISTINCT p.cliente_id) AS total_clientes_distintos
FROM pedidos p
INNER JOIN productos pr ON pr.producto_id = p.producto_id
WHERE p.estado = 'entregado'
GROUP BY pr.producto_id, pr.nombre, pr.categoria, pr.precio
HAVING COUNT(DISTINCT p.cliente_id) > 1;

SELECT * FROM vista_productos_populares
WHERE categoriaProducto = 'Perifericos';

/* 8. Cree la función fn_ingreso_cliente(p_cliente_id INT) que retorne el ingreso total acumulado de un 
cliente (suma de cantidad*precio solo para pedidos entregados, usando JOIN entre pedidos y productos). Luego use esa 
función en un SELECT sobre la tabla clientes para mostrar nombre, ciudad y su ingreso_total, ordenados de mayor a menor
ingreso.
*/

DELIMITER //
CREATE FUNCTION fn_ingreso_cliente(
p_cliente_id INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
	DECLARE v_ingreso_total_acumulado DECIMAL(10, 2);
    SET v_ingreso_total_acumulado = (
		SELECT COALESCE(SUM(p.cantidad * pr.precio), 0) 
        FROM pedidos p
        INNER JOIN productos pr ON pr.producto_id = p.producto_id
        WHERE p.cliente_id = p_cliente_id
        AND p.estado = 'entregado'
    );
    RETURN v_ingreso_total_acumulado;
END //
DELIMITER ;

SELECT 
nombre AS nombreCliente,
ciudad AS ciudadCliente,
fn_ingreso_cliente(cliente_id) AS ingreso_total
FROM clientes
ORDER BY ingreso_total DESC;

/* 9. Cree la función fn_stock_suficiente(p_producto_id INT, p_cantidad_solicitada INT) que retorne 1 si el stock 
actual del producto es mayor o igual a la cantidad solicitada, o 0 en caso contrario. Luego escriba una consulta que 
liste nombre y stock de todos los productos donde fn_stock_suficiente(producto_id, 5) = 0, es decir, productos con menos 
de 5 unidades disponibles.
*/

DELIMITER //
CREATE FUNCTION fn_stock_suficiente(
p_producto_id INT, p_cantidad_solicitada INT 
)
RETURNS TINYINT
DETERMINISTIC 
BEGIN 
	DECLARE v_stock_suficiente INT;
    SET v_stock_suficiente = (
    SELECT pr.stock
    FROM productos pr
    WHERE pr.producto_id = p_producto_id
    );
    IF v_stock_suficiente >= p_cantidad_solicitada THEN RETURN 1;
    ELSE RETURN 0;
    END IF;
END //
DELIMITER ;

SELECT 
nombre AS nombreProducto,
stock AS stockProducto
FROM productos
WHERE fn_stock_suficiente(producto_id, 5) = 0;
    
/* 10. Cree el procedimiento sp_actualizar_estado_pedido(p_pedido_id INT, p_nuevo_estado VARCHAR(20)) 
que: (a) Verifique que el pedido exista (si no, retorne mensaje de error). (b) Inserte un registro en 
log_cambios_estado con el estado anterior y el nuevo. (c) Actualice el estado del pedido. 
(d) Si el nuevo estado es cancelado, restaure el stock del producto correspondiente.
*/

DELIMITER //
CREATE PROCEDURE sp_actualizar_estado_pedido(
IN p_pedido_id INT, 
IN p_nuevo_estado VARCHAR(20),
OUT p_mensaje VARCHAR(200)
)
BEGIN
	DECLARE v_estado VARCHAR(20);
    DECLARE v_pedido_id INT;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
        SET p_mensaje = 'Error: Transacción revertida';
	END;
    SELECT estado, pedido_id INTO v_estado, v_pedido_id
    FROM pedidos WHERE pedido_id = p_pedido_id;
    IF v_pedido_id IS NULL THEN 
		SET p_mensaje = 'Error: El pedido no existe';
	ELSE 
		START TRANSACTION;
        INSERT INTO log_cambios_estado(pedido_id, estado_anterior, estado_nuevo) 
        VALUES (p_pedido_id, v_estado, p_nuevo_estado);
        
        UPDATE pedidos
        SET estado = p_nuevo_estado
        WHERE pedido_id = p_pedido_id;
        
        IF p_nuevo_estado = 'cancelado' THEN 
			UPDATE productos pr
			INNER JOIN pedidos p ON pr.producto_id = p.producto_id
			SET pr.stock = pr.stock + p.cantidad
			WHERE p.pedido_id = p_pedido_id;
		END IF;
	COMMIT;
	SET p_mensaje = CONCAT('Pedido #: ', p_pedido_id, ' cambiado de estado ', v_estado, ' a ', p_nuevo_estado);
	END IF;
END //
DELIMITER ;

/* 11. Cree el procedimiento sp_resumen_cliente(p_cliente_id INT) que ejecute y retorne en un solo 
SELECT: nombre del cliente, ciudad, total de pedidos por estado (use SUM con CASE WHEN para contar pedidos entregados, 
pendientes y cancelados en columnas separadas) y el ingreso total solo de pedidos entregados
*/
        
DELIMITER //
CREATE PROCEDURE sp_resumen_cliente(
IN p_cliente_id INT
)
BEGIN
	SELECT 
    c.nombre,
    c.ciudad,
    SUM(CASE WHEN p.estado = 'entregado' THEN 1 ELSE 0 END) AS pedidos_entregados,
    SUM(CASE WHEN p.estado = 'pendiente' THEN 1 ELSE 0 END) AS pedidos_pendientes,
    SUM(CASE WHEN p.estado = 'cancelado' THEN 1 ELSE 0 END) AS pedidos_cancelados,
    SUM(CASE WHEN p.estado = 'entregado' THEN
		p.cantidad * pr.precio
        ELSE 0 END) AS ingreso_total_entregado
    FROM clientes c
    LEFT JOIN pedidos p ON c.cliente_id = p.cliente_id
    LEFT JOIN productos pr ON pr.producto_id = p.producto_id
    WHERE c.cliente_id = p_cliente_id
    GROUP BY c.cliente_id, c.nombre, c.ciudad;
END//
DELIMITER ;
CALL sp_resumen_cliente(1);

/* 12. Cree la vista vista_pedidos_pendientes que muestre pedido_id, nombre del cliente, nombre del producto, cantidad,
precio unitario y dias_espera (DATEDIFF entre CURDATE() y fecha_pedido) para todos los pedidos con estado pendiente. 
Luego cree el procedimiento sp_alertar_retrasos(p_dias_limite INT) que consulte esa vista y retorne los pedidos cuyo 
dias_espera supere p_dias_limite.
*/

CREATE VIEW vista_pedidos_pendientes AS
	SELECT 
    p.pedido_id,
    c.nombre AS nombreCliente,
    pr.nombre AS nombreProducto,
    p.cantidad,
    pr.precio,
    (DATEDIFF(CURDATE(), p.fecha_pedido)) AS dias_espera
    FROM pedidos p
    INNER JOIN clientes c ON c.cliente_id = p.cliente_id
    INNER JOIN productos pr ON pr.producto_id = p.producto_id
    WHERE p.estado = 'pendiente';

DELIMITER //
CREATE PROCEDURE sp_alertar_retrasos(
IN p_dias_limite INT
)
BEGIN 
	SELECT * FROM vista_pedidos_pendientes
    WHERE dias_espera > p_dias_limite;
END // 
DELIMITER ;

CALL sp_alertar_retrasos(5);

/* 13. Agregue la columna descuento DECIMAL(5,2) DEFAULT 0 a la tabla productos con una restricción CHECK que 
garantice valores entre 0 y 50. Cree la función fn_precio_final(p_producto_id INT) que retorne el precio del producto 
aplicando su descuento (precio * (1 - descuento/100)). Luego escriba una consulta que muestre nombre, precio, descuento 
y precio_final para los 3 productos con mayor precio_final, usando la función.
*/

ALTER TABLE productos ADD descuento DECIMAL(5, 2) DEFAULT 0 CHECK (descuento BETWEEN 0 AND 50);

DELIMITER //
CREATE FUNCTION fn_precio_final(
p_producto_id INT 
)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN 
	DECLARE v_precio DECIMAL(10, 2);
    DECLARE v_descuento DECIMAL(10, 2);
    SELECT precio, descuento INTO v_precio, v_descuento
    FROM productos 
    WHERE producto_id = p_producto_id;
    RETURN v_precio * (1 - v_descuento / 100);
END //
DELIMITER ;

SELECT 
nombre,
precio,
descuento,
fn_precio_final(producto_id) AS precio_final
FROM productos
ORDER BY precio_final DESC
LIMIT 3;

UPDATE productos
SET descuento = 10
WHERE producto_id = 1;

/* 14. Cree el procedimiento sp_registrar_pedido(p_cliente_id INT, p_producto_id INT, p_cantidad INT) que: 
(a) Valide que el cliente exista. (b) Valide que el stock sea suficiente. (c) Inserte el pedido con estado pendiente. 
(d) Actualice el stock descontando la cantidad. (e) Retorne con un SELECT JOIN el pedido recién creado con nombre del 
cliente y nombre del producto.
*/

DELIMITER //
CREATE PROCEDURE sp_registrar_pedido(
IN p_cliente_id INT,
IN p_producto_id INT,
IN p_cantidad INT
)
BEGIN
	DECLARE v_stock INT;
    DECLARE v_cliente_id INT;
    DECLARE v_pedido_id INT;
    
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
		ROLLBACK;
	END;
    
    SELECT cliente_id INTO v_cliente_id
    FROM clientes
    WHERE cliente_id = p_cliente_id;
    
    IF v_cliente_id IS NULL THEN
		SELECT 'Error: El cliente no existe' AS mensaje;
	ELSE 
		SELECT stock INTO v_stock
        FROM productos
        WHERE producto_id = p_producto_id;
        IF v_stock < p_cantidad THEN 
			SELECT 'Error: El stock no es suficiente' AS mensaje;
		ELSE
			START TRANSACTION;
            INSERT INTO pedidos(cliente_id, producto_id, cantidad, estado) VALUES 
            (p_cliente_id, p_producto_id, p_cantidad, 'pendiente'); 
            SET v_pedido_id = LAST_INSERT_ID();
            
            UPDATE productos
            SET stock = stock - p_cantidad
            WHERE producto_id = p_producto_id;
            COMMIT;
            
            SELECT 
            p.pedido_id AS idPedido,
            c.nombre AS nombreCliente,
            pr.nombre AS nombreProducto,
            p.cantidad,
            p.estado
            FROM pedidos p
            INNER JOIN clientes c ON c.cliente_id = p.cliente_id
            INNER JOIN productos pr ON pr.producto_id = p.producto_id
            WHERE p.pedido_id = v_pedido_id;
            
            END IF;
		END IF;
END // 
DELIMITER ;

CALL sp_registrar_pedido(1, 2, 3);

/* 15. Cree la funcion fn_clasificar_producto(p_producto_id INT) que retorne: PREMIUM si el precio > 1,000,000; 
ESTANDAR si esta entre 200,000 y 1,000,000; BASICO si es menor a 200,000. Luego cree la vista vista_catalogo_clasificado 
que muestre nombre, categoria, precio, clasificacion (usando la funcion) y stock para todos los productos. Finalmente, 
consulte la vista mostrando solo los productos PREMIUM con stock > 5.
*/

DELIMITER //
CREATE FUNCTION fn_clasificar_producto(
p_producto_id INT 
)
RETURNS VARCHAR(20)
DETERMINISTIC 
BEGIN
	DECLARE v_precio DECIMAL(10, 2);
    SELECT precio INTO v_precio
    FROM productos
    WHERE producto_id = p_producto_id;
    RETURN CASE
		WHEN v_precio > 1000000 THEN 'PREMIUM'
        WHEN v_precio BETWEEN 200000 AND 1000000 THEN 'ESTANDAR'
        ELSE 'BASICO'
	END;
END //
DELIMITER ;

CREATE VIEW vista_catalogo_clasificado AS
SELECT
nombre,
categoria,
precio,
fn_clasificar_producto(producto_id) AS clasificacionProducto,
stock
FROM productos;

SELECT * FROM vista_catalogo_clasificado
WHERE clasificacionProducto = 'PREMIUM' AND stock > 5;

/* 16. Cree la vista vista_clientes_vip que contenga el cliente_id, nombre, ciudad y total_pedidos_entregados 
de clientes que hayan realizado mas pedidos entregados que el promedio de pedidos entregados por cliente 
(use subconsulta en el HAVING). Luego escriba una consulta sobre esa vista junto con un JOIN a pedidos y 
productos para listar el detalle de los últimos 2 pedidos de cada cliente VIP, mostrando nombre del cliente, 
nombre del producto y fecha_pedido.
*/

CREATE VIEW vista_clientes_vip AS
	SELECT 
    c. cliente_id,
    c.nombre AS nombreCliente,
    c.ciudad,
    COUNT(p.pedido_id) AS total_pedidos_entregados
    FROM clientes c
    INNER JOIN pedidos p ON c.cliente_id = p.cliente_id
    WHERE p.estado = 'entregado'
    GROUP BY c.cliente_id, c.nombre, c.ciudad  -- si selecciono columnas ya hechas y agregaciones (COUNT()) debo decir como agruparlas, ahi es 'quiero una fila por cliente'
    HAVING COUNT(p.pedido_id) > (
		SELECT AVG(total_entregados)
        FROM(
        SELECT COUNT(*) AS total_entregados
        FROM pedidos
        WHERE estado = 'entregado'
        GROUP BY cliente_id
        ) AS sub
	);

SELECT * FROM (
	SELECT 
    v.nombre AS nombreCliente,
    pr.nombre AS nombreProducto,
    p.fecha_pedido,
    ROW_NUMBER() OVER (  -- dividimos datos en grupos
		PARTITION BY v.cliente_id  -- se dividen por el id 
        ORDER BY p.fecha_pedido DESC  -- ordena dentro de cada cliente por fecha 
    ) AS rn
    FROM vista_clientes_vip v
    INNER JOIN pedidos p ON v.cliente_id = p.cliente_id
    INNER JOIN productos pr ON p.producto_id = pr.producto_id
    WHERE p.estado = 'entregado'
) t
WHERE rn >= 2; -- solo los ultimos dos pedidos por cliente

/* 17. Eliminar el campo categoria de la tabla productos, luego cambiar el nombre de la tabla a productosTienda, 
modificar el campo precio a DECIMAL(10, 3) y renombrar el mismo campo a precioProducto, por ultimo vacie esa tabla
*/

ALTER TABLE productos DROP categoria;
ALTER TABLE productos RENAME productosTienda;
ALTER TABLE productos MODIFY precio DECIMAL(10, 3);
ALTER TABLE productos CHANGE precio precioProducto DECIMAL(10, 3);
TRUNCATE TABLE productos;

SET SQL_SAFE_UPDATES = 0;

