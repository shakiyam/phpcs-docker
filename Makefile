MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

all: check_for_updates lint build ## Check for updates, lint, and build

build: ## Build an image from a Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/phpcs

check_for_image_updates: ## Check for image updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$(shell awk -e '/FROM/{print $$2}' Dockerfile | grep composer)" docker.io/composer:latest
	@./tools/check_for_image_updates.sh "$(shell awk -e '/FROM/{print $$2}' Dockerfile | grep php)" docker.io/php:alpine

check_for_library_updates: ## Check for library updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/composer.sh update --no-install

check_for_updates: check_for_image_updates check_for_library_updates ## Check for updates to all dependencies

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: hadolint shellcheck shfmt ## Lint all dependencies

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh phpcs tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn phpcs tools/*.sh
