MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:

ALL_TARGETS := $(shell egrep -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')

.PHONY: $(ALL_TARGETS)

all: check_for_image_updates hadolint shellcheck shfmt update_lockfile build ## Lint, update composer.lock, and build
	@:

build: ## Build an image from a Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh docker.io/shakiyam/phpcs

check_for_image_updates: ## Check for image updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$(shell awk -e '/FROM/{print $$2}' Dockerfile | grep composer)" docker.io/composer:latest
	@./tools/check_for_image_updates.sh "$(shell awk -e '/FROM/{print $$2}' Dockerfile | grep php)" docker.io/php:alpine

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh phpcs tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn phpcs tools/*.sh

update_lockfile: ## Update composer.lock
	@echo -e "\033[36m$@\033[0m"
	@./tools/composer.sh update --no-install

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
