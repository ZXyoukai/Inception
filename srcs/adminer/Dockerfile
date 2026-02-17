FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    php8.2-pgsql \
    php8.2-sqlite3 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Download Adminer
RUN mkdir -p /var/www/html && \
    wget -O /var/www/html/index.php "https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php"

# Configure PHP-FPM to listen on port 9001
RUN sed -i 's/listen = \/run\/php\/php8.2-fpm.sock/listen = 9001/g' /etc/php/8.2/fpm/pool.d/www.conf && \
    mkdir -p /run/php

EXPOSE 9001

CMD ["php-fpm8.2", "-F"]
