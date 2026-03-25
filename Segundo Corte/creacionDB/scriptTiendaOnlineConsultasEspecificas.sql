create database if not exists tiendaOnline;
use tiendaOnline;

create table clientes(
idCliente int primary key auto_increment,
nombreCliente varchar(100) not null,
emailCliente varchar(150) unique,
ciudad varchar(80) null,
creado_en datetime default now()
);

create table productos(
idProducto int primary key auto_increment,
nombreProducto varchar(120) not null,
precioProducto decimal(10,2),
stockProducto int default 0,
categoriaProducto varchar(60)
);

create table pedido(
idPedido int primary key auto_increment,
cantidadProducto int not null,
fechaPedido date,
idClienteFK int,
idProductoFK int,
foreign key (idClienteFK) references clientes(idCliente),
foreign key (idProductoFK) references productos(idProducto)
);

create table cliente_cbackup (
idClienBack int primary key auto_increment,
nombreCliente varchar(100) ,
emailCliente varchar(150),
copiado_en datetime default now()
);

select * from clientes;

select * from productos;

select * from pedido;

describe clientes;
insert into clientes(idCliente,nombreCliente,emailCliente,ciudad) values (NULL,'Ana Garcia','ana@mail.com','Madrid');
insert into clientes(nombreCliente,emailCliente,ciudad) values ('Pedro Perez','pedro@mail.com','Barcelona');
select * from clientes;
 
describe productos;
insert into productos (nombreProducto,precioProducto,stockProducto,categoriaProducto)
values ('Laptop Pro',1200000,15,'Electrónica'), 
('Mouse USB',50000,80,'Accesorios'),
('Monitor 32"',500000,20,'Electrónica'),
('Teclados',100000,35,'Accesorios');

insert into cliente_backup (nombreCliente,emailCliente)
select nombreCliente,emailCliente
from clientes
where creado_en<'2026-03-20';

rename table cliente_cbackup to cliente_backup;

select * from cliente_backup;

describe cliente_backup;

update clientes
set ciudad='Valencia'
where idCliente=1;

-- Actualizar varios campos
select * from productos;

update productos
set
precioProducto=1099000,
stockProducto=10
where idProducto=1;

update productos
set precioProducto=precioProducto * 1.10
where categoriaProducto='Accesorios';

select * from clientes;
delete from clientes 
where idCliente=2;

select * from productos;
delete from productos
where stockProducto=0 AND categoriaProducto='Descatalogado';

/* INSERT
1. Inserta 3 clientes nuevos con nombre, email y ciudad
2. Inserta 2 productos con nombre, precio, stock y categoría
3. Inserta 1 pedido vinculando un cliente y un producto recién creados*/
insert into clientes(nombreCliente,emailCliente,ciudad) values ('Juan Hernandez','juan@mail.com','Roma'),
('Santiago Diaz','santiago@mail.com','Monaco'),
('Samuel Torres','samuel@mail.com','Cusco'),
('Jeronimo Alvarez','jeronimo@mail.com','Tunja');

insert into productos (nombreProducto,precioProducto,stoProdT,categoriaProducto)
values
('Lente de enfoque biconvexa de longitud focal de 20 a 300 mm',5000,9,'Oftalmologia'),
('Blurryface (10th Anniversary) Vinyl Coffee Table Book',600000,20,'Música');

select * from productos;
describe pedido;
insert into pedido(cantidadProducto, fechaPedido, idClienteFK, idProductoFK)
values(3, '2026-03-19', 5, 5);


/*UPDATE
4. Cambia la ciudad de uno de tus clientes insertados
5. Aumenta en 5 unidades el stock de uno de tus productos
6. Modifica el precio del segundo producto aplicando un descuento del 10%*/

-- Le cambiamos la ciudad a Santiago
update clientes
set ciudad='Putumayo'
where idCliente = 4;


-- Le cambiamos el stock al lente 
update productos
set stockProducto = stockProducto + 5
where idProducto=5;

-- Le modificamos el precio al segundo producto
update productos
set precioProducto = precioProducto - (precioProducto * 0.10)
where idProducto = 2;


/*DELETE
7. Elimina el pedido que creaste en el punto 3
8. Elimina el cliente cuya ciudad cambiaste en el punto 4
9. Elimina todos los productos con stock menor a 3
*/

select * from pedido;
delete from pedido
where idPedido = 1;

delete from clientes
where ciudad = 'Putumayo';

delete from productos
where stockProducto < 3;

SET SQL_SAFE_UPDATES = 1;
SET SQL_SAFE_UPDATES = 0;

-- sentencia para consultas
-- SELECT es la transacción se que usa para consultar, existen 
describe productos;
alter table productos change stockProducto stoProdT int(11);
-- 1. Consultas específicas
-- -AS-Alias: para crear un alias se hace SELECT nombreProducto as Nombre_Producto, stoProdT AS stock from productos
SELECT nombreProducto as Nombre_Producto, stoProdT as stock from productos;

-- -Where: Podemos tener condiciones de operación aritmética (+, -, *, /), lógicas (AND, OR, NOT), comparativas (<, >, =) sirve para hacer consulta con condición. Se consulta por CAMPOS
SELECT nombreProducto, stoProdT from productos WHERE idProducto = 1;
SELECT nombreProducto, stoProdT from productos WHERE stoProdT < 15;
SELECT nombreProducto, stoProdT from productos WHERE stoProdT < 15 AND idProducto = 1;
SELECT nombreProducto, stoProdT from productos WHERE stoProdT < 15 AND nombreProducto = "Lente de enfoque biconvexa de longitud focal de 20 a 300 mm";
SELECT nombreProducto, stoProdT from productos WHERE stoProdT > 15 OR idProducto = 1;
SELECT nombreProducto, stoProdT from productos WHERE stoProdT > 25 OR idProducto = 1;
SELECT nombreProducto, stoProdT from productos WHERE NOT stoProdT < 15;

-- BETWEEN: SELECT * FROM NOMBRE_TABLA WHERE column_name BETWEEN VALOR1 AND VALOR2
SELECT nombreProducto as Nombre_Producto, precioProducto as precio
from productos where precioProducto between 500 and 10000 and stoProdT > 3 order by precioProducto asc;

-- -Likes: Buscar caracteres que inicien, terminen o contengan 
-- Que inicien (el porcentaje es para decir que no importa lo que venga después del caracter)
select * from productos where  nombreProducto like 'l%';
-- Que contenga
select * from productos where  nombreProducto like '%l%';
-- Que NO contenga
select * from productos where  nombreProducto not like '%m';
-- Que termine
select * from productos where  nombreProducto like '%m';
-- organiza todo pero solo me muestra los primeros 10 (para eso el LIMIT)
select * from productos where  nombreProducto like '%m' order by precioProducto asc limit 10; 
-- -Subconsulta

-- -Multitabla

-- -operancionesCalculadas

-- -Agrupadas

-- -Ordenadas: SELECT campos FROM nombre_tabla order by campo_a_ordenar formaOrden (ASC para menor a mayor DESC para mayor a menor)
select nombreProducto as Nombre_Producto, stoProdT as stock
from productos order by stoProdT ASC;

select nombreProducto as Nombre_Producto, stoProdT as stock
from productos order by nombreProducto ASC;

select nombreProducto as Nombre_Producto, stoProdT as stock
from productos order by nombreProducto DESC;

-- 2. Consultas generales (SELECT * from nombre_Tabla) donde * muestra todos los campos 
-- SELECT idCliente, docCliente from Cliente de esta forma si queremos campos específicos
SELECT nombreProducto, stoProdT from productos;

DROP DATABASE IF EXISTS tiendaOnline;