USER_ID=$(shell id -u)
GROUP_ID=$(shell id -g)
TAG?=latest

ifneq (,$(filter $(firstword $(MAKECMDGOALS)),npm-install))
    NPM_CLI_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(NPM_CLI_ARGS):;@:)
endif

ifneq (,$(filter $(firstword $(MAKECMDGOALS)),npm-remove))
    NPM_CLI_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(NPM_CLI_ARGS):;@:)
endif

npm = docker run --rm -v $$(pwd):/var/www/phaser -v ${HOME}/.npm:/.npm -v ${HOME}/.config:/.config -w /var/www/phaser -u ${USER_ID}:${GROUP_ID} node:11.9 npm $1

up: install
	docker-compose -f ./docker/docker-compose.yml up -d

down:
	docker-compose -f ./docker/docker-compose.yml down

restart: down up

install:
	$(call npm, install --silent $(NPM_CLI_ARGS))

uninstall:
	$(call npm, remove --silent $(NPM_CLI_ARGS))

rebuild:
	docker build --force-rm -t docker_phaser:$(TAG) ./docker/node

.PHONY: up down restart install uninstall rebuild
