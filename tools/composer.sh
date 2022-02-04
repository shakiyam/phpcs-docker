#!/bin/bash
set -eu -o pipefail

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
      docker.io/composer:2.2 composer "$@"
  else
    podman container run \
      --name composer$$ \
      --rm \
      --security-opt label=disable \
      -v "$PWD"/composer.json:/app/composer.json:ro \
      -v "$PWD"/composer.lock:/app/composer.lock \
      -v "$PWD"/vendor:/app/vendor \
      docker.io/composer:2.2 composer "$@"
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
      docker.io/composer:2.2 composer "$@"
  else
    podman container run \
      --name composer$$ \
      --rm \
      --security-opt label=disable \
      -v "$PWD"/composer.json:/tmp/composer.json:ro \
      -v "$PWD"/composer.lock:/tmp/composer.lock \
      -w /tmp \
      docker.io/composer:2.2 composer "$@"
  fi
fi
