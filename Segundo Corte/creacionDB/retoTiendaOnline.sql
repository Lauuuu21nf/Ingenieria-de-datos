create database tienda_online;
use tienda_online;

create table producto(
idProducto int unique auto_increment primary key,
nombreProducto varchar (20) not null,
precioProducto double not null,
stockProducto int default 0,
fechaCreacionProducto datetime default current_timestamp
);

create table cliente(
idCliente varchar(20) not null primary key,
nombreCliente varchar(50) not null,
emailCliente varchar(50) unique,
telefonoCliente varchar(50) not null
);

create table pedido(
idPedido varchar(50) primary key,
idClienteFK varchar(20) not null,
fecha date,
total double
);
ALTER TABLE pedido
ADD CONSTRAINT FKidClientePedido
FOREIGN KEY (idClienteFK)
REFERENCES cliente (idCliente);

ALTER TABLE producto
ADD COLUMN categoria varchar(50);

ALTER TABLE cliente
modify telefonoCliente varchar(15);

ALTER TABLE pedido
CHANGE total monto_Total DOUBLE;

ALTER TABLE pedido
DROP COLUMN fecha;