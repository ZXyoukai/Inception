FROM debian:latest

WORKDIR /var/www/html


RUN apt-get update && apt-get upgrade -y && apt-get install -y php8.4-fpm php-fpm 
RUN chmod +x /usr/sbin/php-fpm8.4
RUN apt-get install -y curl unzip \
&& curl -o wordpress.tar.gz https://wordpress.org/latest.tar.gz \
&& tar -xzf wordpress.tar.gz --strip-components=1 \
&& rm wordpress.tar.gz

RUN chown -R www-data:www-data /var/www/html \
&& chmod -R 755 /var/www/html

COPY index.php .

ENV PATH=$PATH:/usr/sbin

EXPOSE 9001

CMD [ "php-fpm8.4" , "-F" ]