-- ================================================================
-- CASO: Sistema de Gestion Hospitalaria
-- Tablas: medicos, pacientes, consultas
-- ================================================================
DROP DATABASE IF EXISTS hospital_db;
CREATE DATABASE hospital_db CHARACTER SET utf8mb4;
USE hospital_db;

CREATE TABLE medicos (
    medico_id        INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    especialidad     VARCHAR(80)  NOT NULL,
    salario          DECIMAL(12,2) NOT NULL CHECK (salario > 0),
    fecha_ingreso    DATE NOT NULL,
    activo           TINYINT(1) DEFAULT 1
    );

CREATE TABLE pacientes (
    paciente_id      INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    ciudad           VARCHAR(60),
    email            VARCHAR(100) UNIQUE,
    eps              VARCHAR(80)
);

CREATE TABLE consultas (
    consulta_id      INT AUTO_INCREMENT PRIMARY KEY,
    medico_id        INT NOT NULL,
    paciente_id      INT NOT NULL,
    fecha_consulta   DATE NOT NULL,
    diagnostico      VARCHAR(200),
    costo            DECIMAL(10,2) NOT NULL CHECK (costo > 0),
    estado           VARCHAR(20) DEFAULT "programada"
        CHECK (estado IN ("programada","realizada","cancelada")),
    FOREIGN KEY (medico_id)   REFERENCES medicos(medico_id),
    FOREIGN KEY (paciente_id) REFERENCES pacientes(paciente_id)
);

-- ================================================================
-- DML: DATOS DE PRUEBA
-- ================================================================
INSERT INTO medicos VALUES
 (1,"Dra. Laura Rios","Cardiologia",8500000.00,"2018-03-10",1),
 (2,"Dr. Carlos Mesa","Neurologia",9200000.00,"2016-07-22",1),
 (3,"Dra. Sofia Vega","Pediatria",7800000.00,"2020-01-15",1),
 (4,"Dr. Andres Gil","Ortopedia",8100000.00,"2019-06-01",1),
 (5,"Dra. Paula Mora","Cardiologia",8700000.00,"2017-09-30",1),
 (6,"Dr. Ivan Cruz","Dermatologia",7500000.00,"2021-04-12",0),
 (7,"Dra. Marta Leon","Neurologia",9500000.00,"2015-11-05",1),
 (8,"Dr. Felipe Ossa","Pediatria",7600000.00,"2022-02-28",1);

INSERT INTO pacientes VALUES
 (1,"Juan Perez","1985-04-12","Bogota","juan@mail.com","Sura"),
 (2,"Ana Gomez","1992-08-25","Medellin","ana@mail.com","Compensar"),
 (3,"Luis Vargas","1978-12-03","Cali","luis@mail.com","Sura"),
 (4,"Maria Diaz","2001-06-17","Bogota","maria@mail.com","Famisanar"),
 (5,"Carlos Ruiz","1965-01-30","Barranquilla","carlos@mail.com","Compensar"),
 (6,"Lucia Herrera","1990-09-08","Bogota","lucia@mail.com","Sura"),
 (7,"Pedro Soto","2005-03-22","Cali","pedro@mail.com","Famisanar"),
 (8,"Valeria Torres","1998-11-14","Medellin","valeria@mail.com","Compensar");

INSERT INTO consultas VALUES
 (1,1,1,"2024-01-10","Hipertension leve",150000,"realizada"),
 (2,1,3,"2024-01-22","Control cardiaco",150000,"realizada"),
 (3,2,2,"2024-02-05","Cefalea cronica",200000,"realizada"),
 (4,2,5,"2024-02-18","Migraña",200000,"cancelada"),
 (5,3,4,"2024-03-01","Control crecimiento",90000,"realizada"),
 (6,3,7,"2024-03-14","Fiebre alta",90000,"realizada"),
 (7,4,6,"2024-04-02","Fractura muñeca",250000,"realizada"),
(8,4,1,"2024-04-15","Dolor rodilla",250000,"programada"),
 (9,5,8,"2024-05-03","Arritmia",180000,"realizada"),
 (10,5,2,"2024-05-20","Ecocardiograma",180000,"realizada"),
 (11,6,3,"2024-05-28","Dermatitis",120000,"cancelada"),
 (12,7,5,"2024-06-10","Epilepsia control",220000,"realizada"),
 (13,7,6,"2024-06-22","Resonancia",220000,"programada"),
 (14,8,4,"2024-07-01","Vacunacion",60000,"realizada"),
 (15,1,8,"2024-07-15","Hipertension severa",180000,"realizada"),
 (16,3,2,"2024-07-28","Seguimiento",90000,"programada");


/* 3. Cree la tabla historial_salarios (historial_id PK AUTO_INCREMENT, medico_id FK referencias medicos, salario_anterior DECIMAL(12,2), 
salario_nuevo DECIMAL(12,2), fecha_cambio DATETIME DEFAULT NOW(), motivo VARCHAR(150)). Agregue ademas la restriccion CHECK en consultas 
para que el costo sea mayor a 0 (si no existe). Luego inserte dos registros en historial_salarios reflejando cambios de salario para los 
medicos con id 1 y 3, con los valores que ya existen en la tabla medicos como salario_nuevo.
*/  

-- creación tabla historial_salarios
CREATE TABLE historial_salarios(
historial_id INT AUTO_INCREMENT PRIMARY KEY,
medico_id INT NOT NULL,
FOREIGN KEY (medico_id) REFERENCES medicos(medico_id),
salario_anterior DECIMAL(12, 2),
salario_nuevo DECIMAL(12, 2),
fecha_cambio DATETIME DEFAULT NOW(),
motivo VARCHAR(150)
);

-- YA EXISTE EL CHECK (costo > 0) EN CONSULTAS

-- Inserción dos registros en historial_salario
INSERT INTO historial_salarios(medico_id, salario_anterior, salario_nuevo, motivo) VALUES 
(1, 8500000.00, 8500000.00, 'no hay cambio de salario por instrucciones'),
(3, 7800000.00, 7800000.00, 'no hay cambio de salario por instrucciones');

DESCRIBE historial_salarios;
SELECT * FROM historial_salarios;
DESCRIBE medicos;
DESCRIBE consultas;
SELECT * FROM medicos;

