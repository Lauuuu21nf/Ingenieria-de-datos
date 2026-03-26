# Importar 
1. Usando el asistente de Workbench
   En el panel izquierdo se da click derecho sobre la tabla Table Data Import Wizard y se selecciona el archivo (recomendable .csv ya que el .xlsx a veces falla), se configura el separador entre registros, el separador de columnas, los tipos de datos y se le da a finish.
2. Usando código
   LOAD DATA INFILE 'ruta/archivo.csv'
   INTO TABLE nombre_tabla
   FIELDS TERMINATED BY ','
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;
NOTA: Se pueden importar archivos SQL presionando File en el panel a mano izquierda, Open SQL Script y ejecutando. También se pueden importar JSON pero es recomendable convertirlo a CSV, lo mismo con los XML. Por último los TXT funcionan igual a los CSV si se define el separador en el caso específico.

# Insertar
Si la tabla ya existe, se pueden importar datos desde un CSV con:
1. El asistente de Workbench
   Table Data Import Wizard, seleccionamos el CSV y se elige "Use existing table", se mapean las columnas y se finaliza.
2. Load Data
   LOAD DATA LOCAL INFILE 'archivo.csv'
   INTO TABLE estudiantes
   FIELDS TERMINATED BY ','
   LINES TERMINATED BY '\n'
   IGNORE 1 ROWS;
