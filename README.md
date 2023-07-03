# backup_oracle
Es un script de Bash para generar backups de bases de datos Oracle 18. Utiliza el utilitario expdp para realizar exportaciones de schemas de la base de datos. Los backups se almacenan en un directorio específico y se registra la información en un archivo de log. El script también elimina los backups antiguos para liberar espacio de almacenamiento.

**Resumen:**
El script de shell (Bash) que realiza backups de bases de datos Oracle 18 utilizando el utilitario `expdp`. El script crea directorios para almacenar los backups y los archivos de log, registra mensajes con fecha y hora en el archivo de log, y elimina backups antiguos. Los backups se realizan para cada esquema (usuario) de la base de datos, y se comprimen en un archivo .dmp.gz con el nombre del esquema y la fecha y hora del respaldo.

**Descripción detallada paso a paso:**
1. El script comienza estableciendo variables como el directorio de almacenamiento de backups, nombre de usuario y contraseña de Oracle, host de la base de datos, puerto y directorio para el archivo de log.
2. Se crea el directorio de backups y el directorio para el archivo de log si no existen.
3. Se define una función `log_message` que registra mensajes en el archivo de log con la fecha y hora actual.
4. Se registra un mensaje en el archivo de log para indicar el inicio del script.
5. El script utiliza el comando `expdp` para obtener la lista de esquemas (usuarios) de la base de datos existentes.
6. Si no se encuentran esquemas válidos para respaldar, se registra un mensaje en el archivo de log y el script termina.
7. Se convierte la lista de esquemas en un array para iterar a través de cada uno de ellos.
8. Se itera a través de cada esquema y se realiza el respaldo utilizando el comando `expdp`. El respaldo se almacena en un archivo .dmp.gz con el nombre del esquema y la fecha y hora del respaldo.
9. Si el respaldo se completa correctamente, se registran mensajes en el archivo de log con información sobre el respaldo realizado y su tamaño.
10. Si hay algún error en el respaldo, se registra un mensaje de error en el archivo de log.
11. Si se encuentra un esquema sin nombre o es una base de datos del sistema, se registra una advertencia en el archivo de log y no se realiza el respaldo para ese esquema.
12. Una vez que se han realizado los respaldos, el script busca y borra los archivos de backups con 2 o más días de antigüedad para liberar espacio de almacenamiento.
13. Se registra un mensaje en el archivo de log para indicar la finalización del script.

El script proporciona una forma automatizada de realizar backups de bases de datos Oracle 18 de manera periódica, lo que ayuda a asegurar la integridad de los datos y facilita la recuperación en caso de pérdida o corrupción de datos. Es importante mantener las credenciales de acceso seguras, ya que el script las utiliza para acceder a la base de datos y realizar las exportaciones.