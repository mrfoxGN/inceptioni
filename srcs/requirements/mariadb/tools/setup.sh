#!/bin/bash

set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

INIT_MARKER="/var/lib/mysql/.inception_initialized"

if [ ! -f "${INIT_MARKER}" ]; then

    # Initialize MariaDB data directory if it doesn't exist
    if [ ! -d "/var/lib/mysql/mysql" ]; then
        mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
    fi

    mysqld --user=mysql --bootstrap <<EOSQL
USE mysql;
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
ALTER USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
ALTER USER 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

FLUSH PRIVILEGES;
EOSQL

    touch "${INIT_MARKER}"
    chown mysql:mysql "${INIT_MARKER}"
fi

exec mysqld --user=mysql