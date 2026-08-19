COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/anguenda/data

all: setup
	docker compose -f $(COMPOSE_FILE) up -d --build

setup:
	mkdir -p $(DATA_DIR)/db
	mkdir -p $(DATA_DIR)/wordpress
	@if ! grep -q "anguenda.42.fr" /etc/hosts; then \
		echo "127.0.0.1 anguenda.42.fr" | sudo tee -a /etc/hosts; \
	fi

down:
	docker compose -f $(COMPOSE_FILE) down

stop:
	docker compose -f $(COMPOSE_FILE) stop

clean: down
	docker image prune -f

fclean:
	docker compose -f $(COMPOSE_FILE) down -v
	docker system prune -af
	docker volume prune -f
	sudo rm -rf $(DATA_DIR)

re: fclean all

.PHONY: all setup down stop clean fclean re