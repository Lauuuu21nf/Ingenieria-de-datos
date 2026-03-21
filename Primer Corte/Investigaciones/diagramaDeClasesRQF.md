# Diagrama de Clases
Es un diagrama que describe la estructura de una base de datos futura a modelar mostrando las clases del sistema, sus atributos, operaciones y las relaciones entre objetos.
## Clase
Una clase es un grupo de objetos con funciones similares en la base de datos. Están hechas por atributos y métodos.
## Atributos
Representan las características estructurakes o estáticas de la clase.
## Métodos
Definen las acciones que los objetos pueden hacer.
## Relaciones de clase
- Herencia: Una clase hija hereda los atributos y métodos de una clase padre pero la primera puede tener otros atributos y métodos diferentes de la segunda. Se representa con una línea sólida con una flecha hueca que apunta de la clase hija a la clase padre.
- Asociación: Una relación general entre dos clases, simulando que los objetos de una clase están conectados con los de otra. Existen multiplicidades como 1-1, 1-n, 0...n-m, 1...n-m o n-m y se representa por medio de una línea sólida.
- Agregación: Derivada de la asociación, las partes pueden existir independientemente del todo. Se representa con un rombo blanco.
- Composición: Similar a la agregación, pero las partes no pueden existir sin el todo. Se representa con un rombo negro.

## RQFs
Los requisitos funcionales describen acciones o funciones que el sistema debe hacer, como interactúan los usuarios con la base de datos y qué operaciones se permiten sobre los datos de la misma.
Algunos ejemplos de estos en bases de datos son la gestión de usuarios, CRUD, consultas o la integridad de los datos.
