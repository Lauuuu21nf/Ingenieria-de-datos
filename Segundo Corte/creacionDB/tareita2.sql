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
