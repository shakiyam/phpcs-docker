#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/container_engine.sh

readonly COMPOSER_IMAGE="docker.io/composer:2.10"

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE
if [[ $CONTAINER_ENGINE == docker ]]; then
  ENGINE_OPTS=(-u "$(id -u):$(id -g)")
else
  ENGINE_OPTS=(--security-opt label=disable)
fi
readonly ENGINE_OPTS

[[ -f composer.lock ]] || echo "{}" >composer.lock
if [[ -d "$PWD"/vendor ]]; then
  $CONTAINER_ENGINE container run \
    --name "composer_$(uuidgen | head -c8)" \
    --rm \
    "${ENGINE_OPTS[@]}" \
    -v "$PWD"/composer.json:/app/composer.json:ro \
    -v "$PWD"/composer.lock:/app/composer.lock \
    -v "$PWD"/vendor:/app/vendor \
    "$COMPOSER_IMAGE" composer "$@"
else
  $CONTAINER_ENGINE container run \
    --name "composer_$(uuidgen | head -c8)" \
    --rm \
    "${ENGINE_OPTS[@]}" \
    -v "$PWD"/composer.json:/tmp/composer.json:ro \
    -v "$PWD"/composer.lock:/tmp/composer.lock \
    -w /tmp \
    "$COMPOSER_IMAGE" composer "$@"
fi
