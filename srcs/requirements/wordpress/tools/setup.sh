#!/bin/bash
set -e

echo "Starting WordPress container..."

DB_PASSWORD=$(cat /run/secrets/db_password)

ADMIN_USER=$(grep '^wp_admin_user=' /run/secrets/credentials | cut -d= -f2)
ADMIN_PASSWORD=$(grep '^wp_admin_password=' /run/secrets/credentials | cut -d= -f2)
ADMIN_EMAIL=$(grep '^wp_admin_email=' /run/secrets/credentials | cut -d= -f2)

EDITOR_USER=$(grep '^wp_editor_user=' /run/secrets/credentials | cut -d= -f2)
EDITOR_PASSWORD=$(grep '^wp_editor_password=' /run/secrets/credentials | cut -d= -f2)
EDITOR_EMAIL=$(grep '^wp_editor_email=' /run/secrets/credentials | cut -d= -f2)

echo "Waiting for MariaDB to be ready..."

until mysqladmin ping -h mariadb -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent; do
    echo "Waiting for MariaDB..." ##need to check
    sleep 2
done

echo "MariaDB is ready."

cd /var/www/html

if [ ! -f wp-load.php ]; then
    echo "Downloading WordPress..."
    wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
    echo "Creating wp-config.php..."

    wp config create --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost=mariadb

    echo "wp-config.php created."
fi

if ! wp core is-installed --allow-root; then
    echo "Installing WordPress..."

    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${ADMIN_PASSWORD}" \
        --admin_email="${ADMIN_EMAIL}" \
        --skip-email

    echo "WordPress installed successfully."
else
    echo "WordPress already installed."
fi

if ! wp user get "${EDITOR_USER}" --field=ID --allow-root > /dev/null 2>&1; then
    wp user create --allow-root \
        "${EDITOR_USER}" "${EDITOR_EMAIL}" \
        --role=editor \
        --user_pass="${EDITOR_PASSWORD}"
fi

mkdir -p /run/php

exec php-fpm8.2 -F