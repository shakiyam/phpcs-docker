#!/bin/bash
set -eu -o pipefail

[[ -f composer.lock ]] || touch composer.lock
docker container run \
  --name composer$$ \
  --rm \
  --user "$(id -u)":"$(id -g)" \
  -v "$(pwd)"/composer.json:/tmp/composer.json:ro \
  -v "$(pwd)"/composer.lock:/tmp/composer.lock \
  -w /tmp \
  composer:2.1 composer update
