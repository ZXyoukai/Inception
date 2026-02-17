#!/bin/bash

export MYSQL_PASSWORD=$(tr -d '\n' < /run/secrets/mysql_password)
export MYSQL_ROOT_PASSWORD=$(tr -d '\n' < /run/secrets/mysql_root_password)

service mariadb start

sleep 5

mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;"
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mariadb -e "GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO \`${MYSQL_USER}\`@'%';"
mariadb -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

exec mysqld_safe
