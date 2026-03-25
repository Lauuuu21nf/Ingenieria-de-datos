# Métodos de tipo numérico en MySQL
Existen los enteros que se dividen en TINYINT para números muy pequeños (utilizado para edades), SMALLINT para enteros pequeños, MEDIUMINT para enteros medianos, INT para enteros de uso estándar y los BIGINT para enteros grandes de 8 bytes. También existen los decimales DECIMAL que almacenan valores precisos para definir total e dígitos y decimales, FLOAT para números aproximados de coma flotante y los DOUBLE con precisión doble para, por ejemplo, cálculos estadísticos. Por último estan los BIT(M) que almacena binarios.
# Métodos de tipo carácter en MySQL
Existen VARCHAR para longitud variable y CHAR para longitud fija de hasta 255 caracteres aunque también estan los TEXT y BLOB para textos largos.
# Revertir eliminación de registros pista rollback
Para que sea posible la transacción debe estar activa y antes de un COMMIT. Si se borró algo por error se deshacen los cambios con el comando ROLLBACK;. Tener en cuenta que con el autocommit esto no va a funcionar y para desactivarlo se puede hacer SET autocommi = 0;
