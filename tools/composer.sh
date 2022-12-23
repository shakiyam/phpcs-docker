#!/bin/bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh

[[ -f composer.lock ]] || touch composer.lock
if [[ -d "$PWD"/vendor ]]; then
  if [[ $(command -v docker) ]]; then
    docker container run \
      --name composer$$ \
      --rm \
      --user "$(id -u)":"$(id -g)" \
      -v "$PWD"/composer.json:/app/composer.json:ro \
      -v "$PWD"/composer.lock:/app/composer.lock \
      -v "$PWD"/vendor:/app/vendor \
      docker.io/composer:2.5 composer "$@"
  elif [[ $(command -v podman) ]]; then
    podman container run \
      --name composer$$ \
      --rm \
      --security-opt label=disable \
      -v "$PWD"/composer.json:/app/composer.json:ro \
      -v "$PWD"/composer.lock:/app/composer.lock \
      -v "$PWD"/vendor:/app/vendor \
      docker.io/composer:2.5 composer "$@"
  else
    echo_error 'Neither docker nor podman is installed.'
    exit 1
  fi
else
  if [[ $(command -v docker) ]]; then
    docker container run \
      --name composer$$ \
      --rm \
      --user "$(id -u)":"$(id -g)" \
      -v "$PWD"/composer.json:/tmp/composer.json:ro \
      -v "$PWD"/composer.lock:/tmp/composer.lock \
      -w /tmp \
      docker.io/composer:2.5 composer "$@"
  elif [[ $(command -v podman) ]]; then
    podman container run \
      --name composer$$ \
      --rm \
      --security-opt label=disable \
      -v "$PWD"/composer.json:/tmp/composer.json:ro \
      -v "$PWD"/composer.lock:/tmp/composer.lock \
      -w /tmp \
      docker.io/composer:2.5 composer "$@"
  else
    echo_error 'Neither docker nor podman is installed.'
    exit 1
  fi
fi
