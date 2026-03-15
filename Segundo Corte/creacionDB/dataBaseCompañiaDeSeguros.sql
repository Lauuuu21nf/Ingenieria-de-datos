create database companiaseguros;
use companiaSeguros;
create table compania(
idCompania varchar (50) primary key,
#idCompania int auto_increment si o si entero, y es para que la propia bas elo vaya incrementando
NIT varchar (20) unique  not null,
nombreCompania varchar (50) not null,
fechaFundacion date null,
representanteLegal varchar (50) not null
);

create table seguro(
idSeguro varchar (50) primary key,
estado varchar (20) unique  not null,
valorAsegurado double not null,
costo double not null,
fechaExpiracion date  not null,
idCompaniaFK varchar (50) not null
);

create table automovil(
idAutomovil varchar (50) primary key,
#idCompania int auto_increment si o si entero, y es para que la propia bas elo vaya incrementando
marca varchar (20) unique  not null,
modelo varchar (50) unique not null,
tipos varchar (50) not null,
añoFabricacion date  not null,
serialChasis varchar (50) unique not null,
pasajeros int not null,
cilindraje double not null,
idSeguroFK varchar (50) not null
);

create table detalleAccidente(
idDetalleAccidente varchar (50) primary key,
idAutomovilFK varchar (50) not null,
idAccidenteFK varchar(50)
);

create table Accidente(
idAccidente varchar (50) primary key,
automotores varchar (50) not null,
fatalidades int unique not null,
heridos int unique not null,
lugar varchar(50) unique not null,
fechaAccidente date unique not null
);

