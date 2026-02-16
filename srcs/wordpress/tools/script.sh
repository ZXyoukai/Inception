#!/bin/bash

# Wait for MariaDB
sleep 10


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
fi

exec /usr/sbin/php-fpm8.2 -F
