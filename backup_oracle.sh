#!/bin/bash

# Directorio de almacenamiento de backups
backup_dir="/backups/oracle"

# Nombre de usuario y contraseña de Oracle
db_user="tu_usuario"
db_password="tu_contraseña"

# Host del servidor Oracle
db_host="localhost"
db_port="1521"  # Cambiar al puerto correcto si Oracle Database usa uno diferente al puerto predeterminado (1521).

# Obtener la fecha y hora actual
current_datetime=$(date +"%Y%m%d_%H%M")

# Crear el directorio de backups si no existe
mkdir -p "$backup_dir"

# Directorio para guardar el archivo de log
log_dir="/var/log/scripts"
mkdir -p "$log_dir"

# Archivo de log
log_file="$log_dir/backup_oracle.log"

# Función para registrar mensajes en el archivo de log con fecha y hora
function log_message {
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] $1" >> "$log_file"
}

# Inicio del script
log_message "Inicio del script de backup de bases de datos Oracle."

# Obtener la lista de schemas (usuarios) existentes
schema_list=$(sqlplus -S "$db_user/$db_password@$db_host:$db_port/XE" << EOF
    SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
    SELECT DISTINCT owner FROM all_objects WHERE object_type = 'TABLE';
    EXIT;
EOF
)

# Verificar si se encontraron schemas válidos
if [ -z "$schema_list" ]; then
    log_message "No se encontraron schemas válidos para respaldar. Saliendo del script."
    exit 1
fi

# Convertir la lista de schemas en un array
readarray -t schemas <<< "$schema_list"

# Iterar a través de cada schema y realizar el respaldo
for schema_name in "${schemas[@]}"
do
    # Nombre del archivo de backup
    backup_file="$backup_dir/${schema_name}-PROD-${current_datetime}.dmp"

    # Registro de hora de inicio del backup
    log_message "Inicio del backup del schema $schema_name."

    # Realizar el respaldo utilizando expdp
    echo "Ejecutando comando expdp para respaldar el schema $schema_name..."
    expdp "$db_user/$db_password@$db_host:$db_port/XE" schemas="$schema_name" directory=DATA_PUMP_DIR dumpfile="$backup_file" logfile="$backup_file.log"

    # Verificar si el respaldo se completó correctamente
    if [ $? -eq 0 ]; then
        # Registro de hora de finalización del backup
        log_message "Backup de $schema_name completado: $backup_file"

        # Obtener el peso del backup generado
        backup_size=$(du -h "$backup_file" | cut -f 1)
        log_message "Peso del backup: $backup_size"
    else
        log_message "ERROR: Fallo al respaldar $schema_name"
    fi
done

# Borrar archivos con 2 o más días de antigüedad
log_message "Buscando y borrando archivos de backups con 2 o más días de antigüedad..."
find "$backup_dir" -type f -name "*.