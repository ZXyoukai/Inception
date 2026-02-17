NAME = inception
DOCKER_COMPOSE = ./srcs/docker-compose.yml

all: up

up:
	sudo mkdir -p /home/${USER}/data/mariadb
	sudo mkdir -p /home/${USER}/data/wordpress
	docker-compose -f $(DOCKER_COMPOSE) up -d --build -y

down:
	docker-compose -f $(DOCKER_COMPOSE) down

clean: down
	# docker system prune -a -y
	docker rmi mariadb nginx wordpress redis ftp adminer static-site portainer 2>/dev/null || true

fclean: clean
	docker volume rm mariadb_data wordpress_data redis_data adminer_data portainer_data 2>/dev/null || true
	sudo rm -rf /home/${USER}/data/mariadb
	sudo rm -rf /home/${USER}/data/wordpress

re: fclean all

.PHONY: all up down clean fclean re
