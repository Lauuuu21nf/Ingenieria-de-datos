CREATE DATABASE IF NOT EXISTS tienda_onlineT;
USE tienda_onlineT;
 drop database tienda_onlineT;
CREATE TABLE categorias (
    id_categoria  INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(80) NOT NULL,
    descripcion   TEXT
);
 
CREATE TABLE productos (
    id_producto   INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(120) NOT NULL,
    precio        DECIMAL(10,2) NOT NULL,
    stock         INT DEFAULT 0,
    id_categoria  INT,
    FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria)
);
 
CREATE TABLE clientes (
    id_cliente    INT AUTO_INCREMENT PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    ciudad        VARCHAR(80),
    fecha_registro DATE DEFAULT (CURRENT_DATE)
);
 
CREATE TABLE pedidos (
    id_pedido     INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente    INT NOT NULL,
    fecha_pedido  DATETIME DEFAULT NOW(),
    estado        ENUM('pendiente','enviado','entregado','cancelado') DEFAULT 'pendiente',
    total         DECIMAL(12,2) DEFAULT 0,
    FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente)
);
 
CREATE TABLE detalle_pedido (
    id_detalle    INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido     INT NOT NULL,
    id_producto   INT NOT NULL,
    cantidad      INT NOT NULL,
    precio_unit   DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido)   REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);

-- Datos de prueba
INSERT INTO categorias VALUES (1,'Electrónica','Dispositivos electrónicos'),
    (2,'Ropa','Prendas de vestir'),(3,'Libros','Libros y revistas');
 
INSERT INTO productos VALUES
    (1,'Laptop Pro',18500.00,15,1),(2,'Auriculares BT',650.00,40,1),
    (3,'Camiseta Básica',250.00,100,2),(4,'Python Crash Course',450.00,30,3);
 
INSERT INTO clientes VALUES
    (1,'Ana García','ana@email.com','CDMX','2024-01-10'),
    (2,'Luis Pérez','luis@email.com','GDL','2024-02-15'),
    (3,'María López','maria@email.com','MTY','2024-03-01');
 
INSERT INTO pedidos VALUES
    (1,1,NOW(),'entregado',19150.00),(2,2,NOW(),'enviado',650.00),
    (3,1,NOW(),'pendiente',700.00),(4,3,NOW(),'cancelado',450.00);
 
INSERT INTO detalle_pedido VALUES
    (1,1,1,1,18500.00),(2,1,2,1,650.00),
    (3,2,2,1,650.00),(4,3,3,2,250.00),(5,3,4,1,450.00),(6,4,4,1,450.00);


### Pedidos con el nombre del cliente

describe pedidos;

select p.id_pedido, 
c.nombre as cliente,
c.id_cliente,
c.ciudad,
p.fecha_pedido,
p.estado,
p. total
from pedidos p
inner join clientes c on p.id_cliente=c.id_cliente
order by p.fecha_pedido desc;

select * from pedidos;

### clientes que aun no tengan pedidos

select 
c.nombre as cliente,
c.id_cliente,
c.ciudad,
count(p.id_pedido) as totalPedido
from clientes c
left join pedidos p on c.id_cliente=p.id_cliente
order by p.fecha_pedido desc;

### Join con 3 tablas cliente pedido producto
use tienda_onlinet;

select
c.nombre as cliente,
p.id_pedido,
p.estado,
pr.nombre as producto,
dp.cantidad,
dp.precio_unit,
(dp.cantidad*dp.precio_unit) as Subtotal
from clientes c
inner join pedidos p  on c.id_cliente=p.id_cliente
inner join detalle_pedido dp on p.id_pedido=dp.id_pedido
inner join productos pr  on dp.id_producto=pr.id_producto
order by c.nombre, p.id_pedido;

##=== procedimientos almacenados - funciones - vistas

/* ====== Procedimientos almacenados Stored Procedures=======
son bloques de código de  SQL que tienen un nombre que se almacenan 
en el sevidor y se ejecutan con invocación o llamandolos CALL registro o creacion 
de consulta de modificación o actualización de eliminación

con parametros entrada in  salida out ambos (inout)

sintaxis
--Crear Procedimiento
DELIMITER//
CREATE PROCEDURE nombreProcedimiento(
	IN parametro_entrada tipo,
    OUT parametro_salida tipo,
    INOUT parametro_entradasalida tipo 
)
BEGIN 
-- Declaración de variables locales
DECLARE variable tipo DEFAULT valor;

-- cuerpo del procedimiento
-- sentencias SQL, control flujo ....

END //
    
DELIMITER;
-- Invocar Procedimiento
CALL nombreProcedimiento(valor_entrada, @variable_salida,@variable_entrada_salida);

*/
use tienda_onlinet;

describe detalle_pedido;
-- Ejemplo 1 Registro de un pedido completo
DELIMITER //
CREATE PROCEDURE sp_crear_pedido(
    IN  p_id_cliente  INT,
    IN  p_id_producto INT,
    IN  p_cantidad    INT,
    OUT p_id_pedido   INT,
    OUT p_mensaje     VARCHAR(200)
)
BEGIN
    DECLARE v_stock   INT;
    DECLARE v_precio  DECIMAL(10,2);
    DECLARE v_total   DECIMAL(12,2);
 
    -- Manejador de errores: si algo falla, hace ROLLBACK
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error: transacción revertida';
        SET p_id_pedido = -1;
    END;
 
    -- Validar stock disponible
    SELECT stock, precio INTO v_stock, v_precio
    FROM productos WHERE id_producto = p_id_producto;
 
    IF v_stock < p_cantidad THEN
        SET p_mensaje  = CONCAT('Stock insuficiente. Disponible: ', v_stock);
        SET p_id_pedido = 0;
    ELSE
        START TRANSACTION;
 
        SET v_total = v_precio * p_cantidad;
 
        -- Crear cabecera del pedido
        INSERT INTO pedidos(id_cliente, total)
        VALUES (p_id_cliente, v_total);
        SET p_id_pedido = LAST_INSERT_ID();
 
        -- Insertar detalle
        INSERT INTO detalle_pedido(id_pedido, id_producto, cantidad, precio_unit)
        VALUES (p_id_pedido, p_id_producto, p_cantidad, v_precio);
 
        -- Descontar stock
        UPDATE productos
        SET stock = stock - p_cantidad
        WHERE id_producto = p_id_producto;
 
        COMMIT;
        SET p_mensaje = CONCAT('Pedido #', p_id_pedido, ' creado correctamente');
    END IF;
END //
DELIMITER ;
 

-- INVOCAR O EJECUTAR EL PROCEDIMIENTO 
CALL sp_crear_pedido(1,3,10,@pedido_id,@msg);

select @pedido_id as id_pedido, @msg as mensaje;

select * from pedidos;
select * from detalle_pedido;
select * from productos;

## Tarea hacer  ejemplo de procedimiento con cursor

## Crear un procedimiento almacenado que permita cancelar un pedido:
## Recibir como parametro de entrada el id_pedido y el id_cliente (verificar que el pedido pertenece al cliente)
## Validar que el pedido exista y pertenezca al cliente indicado, si no debe mostrar mensaje de error
## validar que el pedido no este cancelado ni entregado. solo se va a poder cancelar pedidos que esten pendientes o enviado
## Actualizar el estado del pedido a cancelado
## Actualizar o restaurar ek stock de cada producto de ese pedido (detalle_pedido)
## retornar como parametro de salida un mensaje que Pedido#x: Cancelado Stock restauradopara n productos
## 1. exitosa Pedido#x: Cancelado Stock restauradopara n productos
## 2. No exitosa el pedido no existe o no pertenece al cliente

use tienda_onlinet;
DELIMITER //
CREATE PROCEDURE sp_cancelar_pedido(
    IN  p_id_cliente INT,
    IN  p_id_pedido INT,
    OUT p_mensaje VARCHAR(200)
)
BEGIN
    DECLARE v_estado varchar(20);
    DECLARE v_id_cliente INT;
    DECLARE v_num_productos INT;
 
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error: transacción revertida';
	END;
 
    -- Verrificar existencia de pedido y que pertenece al cliente
    SELECT estado,id_cliente INTO v_estado,v_id_cliente
    FROM pedidos WHERE id_pedido = p_id_pedido;
 
    IF v_id_cliente IS NULL THEN 
        SET p_mensaje  = 'Error: el pedido no existe.';
   ELSEIF v_id_cliente<> p_id_cliente then
		SET p_mensaje  = 'Error: el pedido no pertenece al cliente';
	ELSEIF v_estado IN ('cancelado','entregado') then
		SET p_mensaje  = concat('Error: No se puede cancelar un pedido en estado: "',v_estado,'"');
	ELSE
        START TRANSACTION;
		update productos pr
        inner join detalle_pedido dp ON pr.id_producto=dp.id_producto
        set pr.stock=pr.stock+dp.cantidad
        where dp.id_pedido=p_id_pedido;
        
        select count(*) into v_num_productos
        from detalle_pedido
        where id_pedido=p_id_pedido;
        
        update pedidos
        set estado='cancelado'
        where id_pedido=p_id_pedido;
                
        COMMIT;
        SET p_mensaje = CONCAT('Pedido #', p_id_pedido, ' cancelado. Stock restaurado para ', v_num_productos, 'producto(s).');
    END IF;
END //
DELIMITER ;

CALL sp_cancelar_pedido(3,1,@msg);
select @msg;
select * from pedidos;
CALL sp_cancelar_pedido(1, 1, @msg);
select @msg;
CALL sp_cancelar_pedido(1, 3, @msg);
select @msg;

-- convertir ambos procedimientos en una vista, investigar vistas y cursores, hacer ejemplo de procedimiento de ejemplo con cursor
-- primer procedimiento en cursor
DELIMITER //

CREATE PROCEDURE sp_crear_pedido_cursor(
    IN  p_id_cliente INT,
    IN  p_id_producto INT,
    IN  p_cantidad INT,
    OUT p_id_pedido INT,
    OUT p_mensaje VARCHAR(200)
)
BEGIN
    DECLARE done INT DEFAULT 0;

    DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10,2);
    DECLARE v_total DECIMAL(12,2);

    DECLARE cur_producto CURSOR FOR
        SELECT stock, precioProducto
        FROM productos
        WHERE id_producto = p_id_producto;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_mensaje = 'Error: transacción revertida';
        SET p_id_pedido = -1;
    END;

    OPEN cur_producto;

    FETCH cur_producto INTO v_stock, v_precio;

    IF done THEN
        SET p_mensaje = 'Producto no encontrado';
        SET p_id_pedido = 0;
    ELSE
        IF v_stock < p_cantidad THEN
            SET p_mensaje = CONCAT('Stock insuficiente. Disponible: ', v_stock);
            SET p_id_pedido = 0;
        ELSE
            START TRANSACTION;

            SET v_total = v_precio * p_cantidad;

            INSERT INTO pedidos(id_cliente, total)
            VALUES (p_id_cliente, v_total);

            SET p_id_pedido = LAST_INSERT_ID();

            INSERT INTO detalle_pedido(id_pedido, id_producto, cantidad, precio_unit)
            VALUES (p_id_pedido, p_id_producto, p_cantidad, v_precio);

            UPDATE productos
            SET stock = stock - p_cantidad
            WHERE id_producto = p_id_producto;

            COMMIT;

            SET p_mensaje = CONCAT('Pedido #', p_id_pedido, ' creado correctamente');
        END IF;
    END IF;

    CLOSE cur_producto;

END //

DELIMITER ;
describe productos;
-- vista
CREATE VIEW vista_productos AS SELECT precio, stock FROM productos;
CREATE VIEW view_detalle_pedidos AS
SELECT 
c.id_cliente,
c.nombre AS cliente,
c.ciudad,
p.id_pedido,
p.estado,
p.fecha_pedido,
pr.nombre AS producto,
dp.cantidad,
dp.precio_unit,
(dp.cantidad * dp.precio_unit) AS subtotal
FROM clientes c
INNER JOIN pedidos p ON c.id_cliente = p.id_cliente
INNER JOIN detalle_pedido dp ON p.id_pedido
INNER JOIN productos pr ON dp.id_producto = pr.id_producto;

SELECT * FROM view_detalle_pedidos;

USE tienda_onlinet;
-- funciones: Siempre van a devolver un valor. Consulta select con clausula WHERE y no puede modificar datos 
/*
Sintaxis:
DELIMITER //
CREATE FUNCTION nombre_funcion(
parametro1 tipo,
parametro2 tipo
)
RETURNS tipo_retorno
DETERMINISTIC 
NOW(), RAND()
READ SQL DATA
tablas
BEGIN
	DECLARE variable tipo;
    --logica--
*/
-- CALCULAR DESCUENTO POR VOLUMEN
DELIMITER //
CREATE FUNCTION fn_descuentos_volumen(
p_cantidad int, p_precio decimal (10, 2))
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
	DECLARE v_porcentaje decimal(5, 2);  -- 5 enteros y 2 decimales
    DECLARE v_total decimal(12, 2);
    -- definir porcentaje de descuento segun la cantidad comprada
    SET v_porcentaje = case
		WHEN p_cantidad >= 100 THEN 20.00
		WHEN p_cantidad >= 50 THEN 15.00
		WHEN p_cantidad >= 20 THEN 10.00
		WHEN p_cantidad >= 10 THEN 5.00
    END;
    SET v_total = p_cantidad * p_precio * (1-(v_porcentaje/100));
    RETURN round(v_total, 2);  -- como es determinista toca usar una funcion, esta para que redondee
END//
DELIMITER ;
-- invocando la funcion
describe productos;
SELECT 
nombre,
precio,
fn_descuentos_volumen(25, precio) AS TotalConDescuento
from productos;

/* Vistas
Consulta temporal SQL que se almacena en la base de datos. Para un desarrollo como tal no es bueno hacer vistas, digamos grandes proyectos, pero si e sbueno para un tablero de PowerBI¿
No tiene un espacio físico por lo que son temporales
SINTAXIS:
CREATE OR REPLACE view nombre_vista AS 
SELECT...; q hice? :(
-- usar vista
SELECT * FROM nombre_vista;
-- ver la estructura/definicion de la lista
SHOW CREATE VIEW nombre_vista;
-- eliminar una vista
DROP VIEW IF EXISTS nombre_vista;
*/
-- dentro de una vista se puede correr una funcion
-- Vista de resumenes e clientes
-- ti amo
CREATE OR REPLACE VIEW v_resumen_clientes AS 
SELECT 
c.id_cliente,
c.nombre,
c.email,
c.ciudad,
count(p.id_pedido) AS total_pedidos,
coalesce(sum(p.total), 0) AS monto_total,
coalesce (avg(p.total), 0) AS ticket_promedio,
max(p.fecha_pedido) AS fecha_ultimo_pedido,
fn_clasificar_cliente(c.id_cliente) AS segmento
 -- clasificar los clientes segun el historial de compras que tenga -> tarea
 FROM clientes c
 LEFT JOIN pedidos p ON c.id_cliente = p.id_cliente
 AND p.estado != 'cancelado'
 group by c.id_cliente, c.nombre, c.ciudad, c.email, c.ciudad;
 
SELECT * FROM v_resumen_clientes ORDER BY monto_total desc;
 
SELECT nombre AS cliente, segmento FROM v_resumen_clientes WHERE ciudad = 'Bogota' ORDER BY monto_total desc;

-- Tarea hacer la función para clasificar clientes
DELIMITER //
CREATE FUNCTION fn_clasificar_cliente(c_id_cliente int)
RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
	DECLARE v_categoria VARCHAR(20);
    DECLARE v_total_pedidos INT;
    
    SET v_total_pedidos = (
    SELECT COUNT(*) 
    FROM pedidos
    WHERE id_cliente = c_id_cliente
    );
    
    SET v_categoria = CASE
		WHEN v_total_pedidos >= 20 THEN 'VIP'
        WHEN v_total_pedidos >= 15 THEN 'ALTA'
        WHEN v_total_pedidos >= 10 THEN 'MEDIA'
        WHEN v_total_pedidos >= 5 THEN 'BAJA'
        ELSE 'NUEVO'
	END;
    RETURN concat('Clasificación: ', v_categoria, ' Pedidos: ', v_total_pedidos);
END//
DELIMITER ;
DROP FUNCTION IF EXISTS fn_clasificar_cliente;
select * from clientes;
SELECT 
nombre,
fn_clasificar_cliente(id_cliente) AS clasificacionCliente
from clientes;

/*OJO CON EL DROP DATABASE O DROP TABLE
nos va a dar tres tablas relacionadas y nos va a dar el script de crear la base de datos (puede tener errores), de crear las tablas, y algunas insericones (la sintaxis puede estar mal). 
Van a haber 16 puntos, algunos haga un procedimiento, una vista que tenga promedio, etc, cada uno va a tener un punto (nos sortean los mas faciles del 1 al 9) DDL Y DML HASTA VISTAS 
el taller es parecido*/

