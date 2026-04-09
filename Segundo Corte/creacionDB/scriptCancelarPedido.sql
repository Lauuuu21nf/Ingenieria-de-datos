create database nuevaBaseEmpleados;
use nuevaBaseEmpleados;


create table producto(
idProducto int primary key,
nombreProducto varchar(20),
precioProducto decimal(10, 2),
categoriaProducto varchar(20)
);

create table departamento(
idDepartamento int primary key,
nombreDepartamento varchar(20)
);

create table empleados(
idEmpleado int primary key,
nombreEmpleado varchar(20),
idDeptoFK int,
foreign key (idDeptoFK) references departamento(idDepartamento),
salarioEmpleado decimal(10, 2)
);

select * from departamento;
insert into empleados(idEmpleados, nombreEmpleado, salarioEmpleado, idDeptoFK) values (1, 'Juan',  100000, 1),
(2, 'JuanDa',  100000, 2),
(3, 'JuanFe',  20000, 3),
(4, 'JuanMa',  300000, 2),
(5, 'JuanSe',  5000000, 1);

select * from empleados;

insert into departamento(idDepartamento, nombreDepartamento) values (1, 'Huila'),
(2, 'Mosquera'),
(3, 'La Vega');

insert into producto(idProducto, nombreProducto, precioProducto, categoriaProducto) values (1, 'Lente', 10000, 'Lacteos'),
(2, 'Pan', 20, 'Electronica'),
(3, 'Queso', 300, 'Lacteos'),
(4, 'Lechuga', 60000, 'Veggies'),
(5, 'Pepinillos', 9000, 'Veggies');

insert into producto(idProducto, nombreProducto, precioProducto, categoriaProducto) values (6, 'Cable Unifilar', 5000000, 'Carnes');
insert into producto(idProducto, nombreProducto, precioProducto, categoriaProducto) values (7, 'Cable inalambrico', 5000000, 'Carnes');

drop database nuevaBaseEmpleados; 

/* subconsulta */
-- WHERE
select nombreEmpleado, salarioEmpleado
from empleados
where salarioEmpleado >
(select AVG(salarioEmpleado)
from empleados);

-- WHERE + IN
select nombreEmpleado, salarioEmpleado
from empleados
where idDeptoFK in 
(select idDepartamento
from departamento
where nombreDepartamento in ('Huila', 'La Vega'));

-- tabla derivada
select idDeptoFK, promedio_salario
from
(select idDeptoFK, AVG(salarioEmpleado) as promedio_salario
from empleados
group by idDeptoFK) as promedios -- toda la consulta se va a llamar promedios
where promedio_salario > 1000;                                
-- como es una tabla virtual que no existe en la base, el from va a venir de la tabla que se crea de la consulta, por eso se pone el select dentro del from

select nombreEmpleado, salarioEmpleado, 
(select AVG(salarioEmpleado) from empleados) as prom_general, 
salarioEmpleado - (select AVG(salarioEmpleado) from empleados) as desv_promedio
from empleados;

select nombreProducto, precioProducto
from producto
where precioProducto > (select AVG(precioProducto) from producto)
order by precioProducto desc;

select * from producto;

create table pedido(
idPedido int primary key,
idEmpleadoFK int,
foreign key (idEmpleadoFK) references empleados(idEmpleados),
fechaPedido datetime,
estadoPedido varchar(20),
cantidad int,
precioUnidad decimal(10, 2)
);

create table detallePedido(
idDetallePedido int primary key,
idProductoFK int,
foreign key (idProductoFK) references producto(idProducto),
idPedidoFK int,
foreign key (idPedidoFK) references pedido(idPedido)
);

insert into pedido(idPedido, idEmpleadoFK, fechaPedido, estadoPedido, cantidad, precioUnidad) values (1, 1, '2026-03-25', 'entregado', 2, 20000),
(2, 2, '2026-03-25', 'pendiente', 3, 30000),
(3, 3, '2026-03-25', 'preparando', 3, 40000);

insert into detallePedido(idDetallePedido, idProductoFK, idPedidoFK) values (1, 1, 1),
(2, 1, 1),
(3, 1, 1);

insert into detallePedido(idDetallePedido, idProductoFK, idPedidoFK) values (4, 2, 1),
(5, 3, 1);

insert into detallePedido(idDetallePedido, idProductoFK, idPedidoFK) values (6, 2, 2),
(7, 3, 3);
-- Consultas multitabla min 2 tablas
-- JOINS se pueden hacer así las tablas no estén relacionadas entre sí

-- LEFT muestra todas las filas de la tabla izquierda más las que tiene coincidencia con la derecha, si no existe, muestra un join 
-- la que ponga primera en la sintaxis es la izquierda y la otra es la derecha

-- RIGHT muestra todas las filas de la tabla derecha más las que tiene coincidencia con la izquierda, si no existe, muestra un join 

-- FULL (INNER) solo muestra las filas que tiene coincidencia en ambas tablas (intersección)

-- CROSS producto cartesiano, muestra todas las posibles combinaciones que hay entre las n tablas

-- selfJoin es consultas consigo mismo

-- se le ponen identificadores a las tablas (digamos empleado es e), luego para identificar se hace e.nombre

-- pedidos con el nombre del clientes muestra los clientes que tengan pedido
select p.idPedido, 
e.nombreEmpleado as clente,
d.idDepartamento,
p.fechaPedido,
p.estadoPedido,
p.cantidad
from pedido p
inner join cliente c on p.idClienteFK = c.idCliente
order by p.fecha desc;

-- clientes que aun no tengan pedido
select 
e.nombreEmpleado as cliente,
d.idDepartamento,
count(p.idPedido) as totalPedido
from empleados e
left join pedido p on e.idEmpleado = p.idEmpleadoFK
order by p.fecha desc;

--  mostrar el detalle completo de los pedidos cliente, que pedidos tiene y ese pedido que productos tiene agregado clientes-pedido-producto
select
e.nombreEmpleado as empleado,
p.idPedido,
p.fechaPedido,
p.estadoPedido,
p.cantidad,
pr.nombreProducto as producto,
(p.cantidad*p.precioUnidad) as SubTotal
from empleados e
inner join pedido p on p.idEmpleadoFK = e.idEmpleados
inner join detallePedido d on d.idPedidoFK = p.idPedido 
inner join producto pr on pr.idProducto = d.idProductoFK
order by e.nombreEmpleado, p.idPedido;
select * from pedido;

/* Procedimientos almacenados: Bloques de código de SQL que tienen un nombre y que se almacenan en el servidor y se ejecutan con una invocación (llamandolos) CALL
pueden ser de registro o de consulta, de modificación o actualización de eliminación
parámetros de entrada in, salida out, ambos inout
sintaxis para crear procedimientos:
-- DELIMITER//
CREATE PROCEDURE nombreProcedimiento(
	IN parametro_entrada tipo,
    OUT parametro_salida tipo,
    INOUT parametro_entradaSalida tipo
)
BEGIN
---- Declaración de variables locales
DECLARE variable tipo DEFAULT valor;

---- Cuerpo del procedimiento
sentencias SQL, control flujo...

END//
-- DELIMITER;

sintaxis para invocar procedimientos:
CALL nombreProcedimiento(valor_entrada, @variable_salida, @variable_entrada_salida)

*/
-- Ejemplo 1: Registro de un pedido completo
DELIMITER //
CREATE PROCEDURE crearPedido(
	IN p_id_Empleado INT,
    IN p_id_Producto INT,
    IN p_Cantidad INT,
    OUT p_id_Pedido INT,
    OUT p_mensaje VARCHAR(200)
)
BEGIN 
	DECLARE v_stock INT;
    DECLARE v_precio DECIMAL(10, 2);
    DECLARE v_total DECIMAL(10, 2);
    -- mensaje de error
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SET p_mensaje = 'ERROR: Transacción no realizada';
            SET p_id_pedido = -1;
		END;
        -- validar si hay stock disponible (añadir stock a producto)
        SELECT stock, precioProducto INTO v_stock, v_precio
        FROM producto WHERE idProducto = p_id_producto;
        IF v_stock < p_cantidad THEN
			SET p_mensaje = CONCAT('Stock insuficiente. Disponible: ', v_stock);
			SET p_id_pedido = 0;
        ELSE
			START TRANSACTION;
			SET v_total = v_precio * p_cantidad;
			-- Crear pedido
			INSERT INTO pedido(idEmpleadoFK, total) VALUES(p_id_cliente, v_total);
			SET p_id_pedido = LAST_INSERT_ID();
			-- Insertar el detalle
			INSERT INTO detallePedido(idPedidoFK, idProductoFK, cantidad, precioUnitario) VALUES(p_id_pedido, p_id_producto, p_cantidad, v_precio);
			SET p_id_pedido = LAST_INSERT_ID();
			-- Descontar del stock
			UPDATE productos
			SET stock = stock - p_cantidad
			WHERE idProducto = p_id_producto;
			
			COMMIT;
			SET p_mensaje = CONCAT('Pedido #', p_id_pedido, ' creado correctamente');
        END IF;
END //
DELIMITER ;
-- invocar o ejecutar el procedimiento
CALL crearPedido(1, 3, 10, @pedido_id, @msg);
select @pedido_id as id_pedido, @msg as mensaje;
select * from pedido;

describe pedido;
describe detallePedido;

-- crear un procedimiento almacendo que permita cancelar un pedido:
-- recibir como parametro de entrada el id_pedido y el id_cliente (verificar que el pedido pertenece al cliente)
-- validad que el pedido exista y pertenece al cliente indicado, si no pertenece debe mostrar mensaje de error (select)
-- validar que el pedido no esté cancelado ni entregado, solo se va a poder cancelar pedidos que esten pendientes o enviado
-- actualizar el estado del pedido a cancelado
-- actualizar o restaurar el stock de cada producto de ese pedido (detallePedido) se hace un inner join entre detalle pedido y producto
-- retornar como parametro de salida un mensaje que diga Pedido #x cancelado Stock restaurado para n productos. Sea n la cantidad de productos que habian en el pedido
-- 1. Prueba exitosa
-- 2. Prueba no exitosael pedido no existe o no pertenece al cliente 
-- declarar como variables idCliente, estado y numeros de productos que se devuelven 

DELIMITER //
CREATE PROCEDURE eliminarPedido(
	IN p_idEmpleado INT,
    IN p_idPedido INT,
    OUT p_mensaje VARCHAR(200)
)
BEGIN 
	DECLARE v_idEmpleado INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_numeroProductos INT;
    -- mensaje de error
		DECLARE EXIT HANDLER FOR SQLEXCEPTION
        BEGIN
			ROLLBACK;
            SET p_mensaje = 'ERROR: Transacción no realizada';
            SET p_idPedido = 1;
		END;
        -- validar si el pedido existe y si pertenece al cliente
        SELECT estado, idEmpleado INTO v_estado, v_idEmpleado
        FROM pedidos WHERE idPedido = p_id_Pedido;
        IF v_idEmpleado IS NULL THEN
			SET p_mensaje = ('Error: El pedido no existe');
        ELSEIF v_idEmpleado <> p_idEmpleado THEN
			SET p_mensaje = ('Error: El pedido no pertenece al cliente');
		ELSEIF v_estado IN ('cancelado', 'entregado') then
			SET p_mensaje = concat('ERROR: No se puede calcelar. El estado del pedido es', v_estado);
		ELSE 
			START TRANSACTION;
			UPDATE producto pr
            INNER JOIN detallePedido dp ON pr.idProducto = dp.idProductoFK
            set pr.stock = pr.stock + dp.cantidad
            where dp.idPedidoFK = p_idPedido;
            
            update pedidos 
            set estado = 'cancelado'
            where idPedido = p_idPedido;
            
            COMMIT;
            set p_mensaje = CONCAT("Pedido", p_idPedido, 'canceldo. Stock restaurado para # ', v_numeroProductos, 'productos');
        END IF;
END //
DELIMITER ;

ALTER TABLE producto
ADD stockProducto INT;
SELECT * FROM producto;
-- Funciones 


-- Vistas: consultas virtuales que no existen
-- convertir ambos procedimientos en una vista 