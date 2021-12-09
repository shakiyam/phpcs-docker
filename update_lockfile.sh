#!/bin/bash
set -eu -o pipefail

[[ -f composer.lock ]] || touch composer.lock
if [[ $(command -v podman) ]]; then
  podman container run \
    --name composer$$ \
    --rm \
    --security-opt label=disable \
    -v "$PWD"/composer.json:/tmp/composer.json:ro \
    -v "$PWD"/composer.lock:/tmp/composer.lock \
    -w /tmp \
    docker.io/composer:2.1 composer update
else
  docker container run \
    --name composer$$ \
    --rm \
    --user "$(id -u)":"$(id -g)" \
    -v "$(pwd)"/composer.json:/tmp/composer.json:ro \
    -v "$(pwd)"/composer.lock:/tmp/composer.lock \
    -w /tmp \
    composer:2.1 composer update
fi
