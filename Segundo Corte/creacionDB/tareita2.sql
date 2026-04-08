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

insert into empleados(idEmpleado, nombreEmpleado, salarioEmpleado, idDeptoFK) values (1, 'Juan',  100000, 1),
(2, 'JuanDa',  100000, 2),
(3, 'JuanFe',  20000, 3),
(4, 'JuanMa',  300000, 2),
(5, 'JuanSe',  5000000, 1);

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
foreign key (idEmpleadoFK) references empleados(idEmpleado),
fechaPedido datetime,
estadoPedido varchar(20),
cantidad int,
precioUnidad decimal(10, 2)
);

create table detallePedido(
idDetallePedido int primary key,
idProductoFK int,
foreign key (idProductoFK) references producto(idProducto),
idEmpleadoFK int,
foreign key (idEmpleadoFK) references empleados(idEmpleado)
);

insert into pedido(idPedido, idEmpleado, fechaPedido, estadoPedido, cantidad, precioUnidad) values (1, 1, 25-03-26, 'entregado', 2, 20000)
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
