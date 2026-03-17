/*
Autor: Laura Naar
*/
#creamos la base de datos
create database companiaseguros;
#habilitamos la bas de datos
use companiaSeguros;

#creamos la tabla compañia
create table compania(
idCompania varchar (50) primary key,
#idCompania int auto_increment si o si entero, y es para que la propia bas elo vaya incrementando
NIT varchar (20) unique  not null,
nombreCompania varchar (50) not null,
fechaFundacion date null,
representanteLegal varchar (50) not null
);

#creamos la tabla seguro
create table seguro(
idSeguro varchar (50) primary key,
estado varchar (20) not null,
valorAsegurado double not null,
costo double not null,
fechaExpiracion date  not null,
idCompaniaFK varchar (50) not null,
idAutomovilFK varchar (50) not null
);
#agregamos la FK de idCompañia a seguro para crear la relacion compañia-seguro
ALTER TABLE seguro
ADD CONSTRAINT FKCompaniaSeguro
FOREIGN KEY (idCompaniaFK)
REFERENCES compania (idCompania);

#creamos la tabla automovil
create table automovil(
idAutomovil varchar (50) primary key,
marca varchar (20) not null,
modelo varchar (50) not null,
tipos varchar (50) not null,
añoFabricacion date  not null,
serialChasis varchar (50) unique not null,
pasajeros int not null,
cilindraje double not null
);
#agregamos la FK idAutomovil a seguro para crear la relacion automovil-seguro
ALTER TABLE seguro
ADD CONSTRAINT FKAutomovilSeguro
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil (idAutomovil);

#creamos la tabla detalleAccidente para romper la relacion N:M entre accidentes y automoviles
create table detalleAccidente(
idDetalleAccidente varchar (50) primary key,
idAutomovilFK varchar (50) not null,
idAccidenteFK varchar(50) not null
);

#agregamos la FK de idAutomovil a detalleAccidente para crear la relacion automovil-detalleAccidente
ALTER TABLE detalleAccidente
ADD CONSTRAINT FKdetalleAccidenteAutomovil
FOREIGN KEY (idAutomovilFK)
REFERENCES automovil (idAutomovil);

#creamos la tabla accidente
create table Accidente(
idAccidente varchar (50) primary key,
automotores varchar (50) not null,
fatalidades int  not null,
heridos int  not null,
lugar varchar(50)  not null,
fechaAccidente date not null
);

#agregamos la FK de idAccidente a detalleAccidente para crear la relacion accidente-detalleAccidente
ALTER TABLE detalleAccidente
ADD CONSTRAINT FKdetalleAccidenteAccidente
FOREIGN KEY (idAccidenteFK)
REFERENCES accidente (idAccidente);

#cambiamos el nombre de la tabla automovil por auto
ALTER TABLE automovil
RENAME TO auto;

#eliminamos el campo marca de la tabla auto
ALTER TABLE auto
DROP COLUMN marca;

#eliminamos la llave foránea idAccidenteFK de detalleAccidente, se usa el nombre de la constraint
ALTER TABLE detalleAccidente
DROP FOREIGN KEY FKdetalleAccidenteAccidente;





