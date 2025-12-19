FROM debian:bullseye

RUN apt-get update && apt-get install -y mariadb-server

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY ./tools/script.sh /usr/local/bin/script.sh

RUN chmod +x /usr/local/bin/script.sh
RUN mkdir -p /var/run/mysqld && chown -R mysql:mysql /var/run/mysqld && chmod 777 /var/run/mysqld

EXPOSE 3306

ENTRYPOINT [ "/usr/local/bin/script.sh" ]
