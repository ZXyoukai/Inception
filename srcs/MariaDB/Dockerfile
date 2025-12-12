from debian:12

run apt-get update && apt-get install -y mariadb-server

expose 3306

ENTRYPOINT [ "sh" , "-c", "mysqld_safe" ]