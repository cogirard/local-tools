include .env

COMPOSE_FILE ?= compose.yml
ifneq ("$(wildcard compose.override.yml)","")
    COMPOSE_FILE := compose.yml:compose.override.yml
endif

DOCKER_COMPOSE := COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose

export COMPOSE_FILE COMPOSE_PROJECT_NAME SERVER_NAME TRAEFIK_UI_PORT MAILPIT_UI_PORT

up: # starts containers
	$(DOCKER_COMPOSE) up -d

down: # stops and remove containers
	$(DOCKER_COMPOSE) down

restart: # restarts containers
	$(DOCKER_COMPOSE) restart

build: # build des images du projet
	$(eval service :=)
	$(DOCKER_COMPOSE) build --no-cache $(service)

full-restart: # command down then up
	$(MAKE) down
	$(MAKE) up
