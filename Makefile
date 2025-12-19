NAME = inception
DOCKER_COMPOSE = ./srcs/docker-compose.yml

all: up

up:
	mkdir -p /home/dgermano/data/mariadb
	mkdir -p /home/dgermano/data/wordpress
	docker-compose -f $(DOCKER_COMPOSE) up -d --build

down:
	docker-compose -f $(DOCKER_COMPOSE) down

clean: down
	docker system prune -a

fclean: clean
	sudo rm -rf /home/dgermano/data/mariadb/*
	sudo rm -rf /home/dgermano/data/wordpress/*
	docker volume rm $$(docker volume ls -q) || true

re: fclean all

.PHONY: all up down clean fclean re
