include .env

export COMPOSE_PROJECT_NAME

up:
	docker compose up -d

down: 
	docker compose down

restart:
	docker compose restart

full-restart:
	$(MAKE) down
	$(MAKE) up
