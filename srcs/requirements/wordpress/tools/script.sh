#!/bin/bash
export MYSQL_PASSWORD=$(tr -d '\n' < /run/secrets/db_password)
export WP_ADMIN_PASSWORD=$(tr -d '\n' < /run/secrets/wordpress_admin_password)
export WP_PASSWORD=$(tr -d '\n' < /run/secrets/credentials)
# Wait for MariaDB
MAX_DB_RETRIES=30
DB_RETRY_DELAY=2
DB_HOST="mariadb"
DB_PORT="3306"

attempt=0

while ! mysqladmin ping -h"${DB_HOST}" -P"${DB_PORT}" -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" --silent >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if [ "${attempt}" -ge "${MAX_DB_RETRIES}" ]; then
        echo "Error: MariaDB is not available after ${MAX_DB_RETRIES} attempts. Exiting." >&2
        exit 1
    fi
    echo "Waiting for MariaDB to be ready... (attempt ${attempt}/${MAX_DB_RETRIES})"
    sleep "${DB_RETRY_DELAY}"
done
if [ ! -f /var/www/html/wp-config.php ]; then

    wp core download --allow-root --path='/var/www/html'    
    
    wp config create --allow-root \
        --dbname=$MYSQL_DATABASE \
        --dbuser=$MYSQL_USER \
        --dbpass=$MYSQL_PASSWORD \
        --dbhost=mariadb:3306 \
        --path='/var/www/html'

    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title="$WP_TITLE" \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL \
        --path='/var/www/html'

    wp user create --allow-root \
        $WP_USER $WP_EMAIL \
        --user_pass=$WP_PASSWORD \
        --role=contributor \
        --path='/var/www/html'
    
    # Install and configure Redis Object Cache plugin
    wp plugin install redis-cache --activate --allow-root --path='/var/www/html'
    
    # Configure Redis in wp-config.php
    wp config set WP_REDIS_HOST redis --allow-root --path='/var/www/html'
    wp config set WP_REDIS_PORT 6379 --raw --allow-root --path='/var/www/html'
    wp config set WP_CACHE true --raw --allow-root --path='/var/www/html'
    
    # Enable Redis cache
    wp redis enable --allow-root --path='/var/www/html'
fi

exec /usr/sbin/php-fpm8.2 -F
