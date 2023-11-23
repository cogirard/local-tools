include .env

COMPOSE_FILE ?= compose.yml
ifneq ("$(wildcard compose.override.yml)","")
    COMPOSE_FILE := compose.yml:compose.override.yml
endif

DOCKER_COMPOSE := COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker compose

export COMPOSE_FILE COMPOSE_PROJECT_NAME

up: # starts containers
	$(DOCKER_COMPOSE) up -d

down: # stops and remove containers
	$(DOCKER_COMPOSE) down

restart: # restarts containers
	$(DOCKER_COMPOSE) restart

full-restart: # command down then up
	$(MAKE) down
	$(MAKE) up
