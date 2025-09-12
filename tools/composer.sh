#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

[[ -f composer.lock ]] || echo "{}" >composer.lock
if [[ -d "$PWD"/vendor ]]; then
  if command -v docker &>/dev/null; then
    docker container run \
      --name "composer_$(uuidgen | head -c8)" \
      --rm \
      --user "$(id -u)":"$(id -g)" \
      -v "$PWD"/composer.json:/app/composer.json:ro \
      -v "$PWD"/composer.lock:/app/composer.lock \
      -v "$PWD"/vendor:/app/vendor \
      docker.io/composer:2.8 composer "$@"
  elif command -v podman &>/dev/null; then
    podman container run \
      --name "composer_$(uuidgen | head -c8)" \
      --rm \
      --security-opt label=disable \
      -v "$PWD"/composer.json:/app/composer.json:ro \
      -v "$PWD"/composer.lock:/app/composer.lock \
      -v "$PWD"/vendor:/app/vendor \
      docker.io/composer:2.8 composer "$@"
  else
    echo_error 'Neither docker nor podman is installed.'
    exit 1
  fi
else
  if command -v docker &>/dev/null; then
    docker container run \
      --name "composer_$(uuidgen | head -c8)" \
      --rm \
      --user "$(id -u)":"$(id -g)" \
      -v "$PWD"/composer.json:/tmp/composer.json:ro \
      -v "$PWD"/composer.lock:/tmp/composer.lock \
      -w /tmp \
      docker.io/composer:2.8 composer "$@"
  elif command -v podman &>/dev/null; then
    podman container run \
      --name "composer_$(uuidgen | head -c8)" \
      --rm \
      --security-opt label=disable \
      -v "$PWD"/composer.json:/tmp/composer.json:ro \
      -v "$PWD"/composer.lock:/tmp/composer.lock \
      -w /tmp \
      docker.io/composer:2.8 composer "$@"
  else
    echo_error 'Neither docker nor podman is installed.'
    exit 1
  fi
fi
