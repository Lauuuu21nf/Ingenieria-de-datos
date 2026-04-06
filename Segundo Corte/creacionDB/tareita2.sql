create database nuevaBaseEmpleados;
use nuevaBaseEmpleados;


create table producto(
idProducto int primary key auto_increment,
nombreProducto varchar(20),
precioProducto double,
categoriaProducto varchar(20)
);

create table departamento(
idDepartamento int primary key auto_increment,
nombreDepartamento varchar(20)
);

create table empleados(
idEmpleados int primary key auto_increment,
nombreEmpleado varchar(20),
idDeptoFK int,
foreign key (idDeptoFK) references departamento(idDepartamento),
salarioEmpleado double
);

insert into empleados(nombreEmpleado, salarioEmpleado, idDeptoFK) values ('Juan',  100000, 'Huila'),
('JuanDa',  100000, 'Huila'),
('JuanFe',  20000, 'La Vega'),
('JuanMa',  300000, 'Mosquera'),
('JuanSe',  5000000, 'Mosquera');

insert into departamento(nombreDepartamento) values ('Huila'),
('Mosquera'),
('La Vega');

insert into producto(nombreProducto, precioProducto, categoriaProducto) values ('Lente', 10000, 'Lacteos'),
('Pan', 20, 'Electronica'),
('Queso', 300, 'Lacteos'),
('Lechuga', 60000, 'Veggies'),
('Pepinillos', 9000, 'Veggies');

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
select idDepartamento, promedio_salario
from
(select idDepartamento, AVG(salarioEmpleado) as promedio_salario
from empleados
group by idDepartamento) as promedios -- toda la consulta se va a llamar promedios
where promedio_salario > 1000;                                
-- como es una tabla virtual que no existe en la base, el from va a venir de la tabla que se crea de la consulta, por eso se pone el select dentro del from

select nombreEmpleado, salarioEmpleado, prom_general, desv_promedio
from
(select salarioEmpleado, AVG(salarioEmpleado) as prom_general 
from 
(select salarioEmpleado, )

