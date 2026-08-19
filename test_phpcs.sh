#!/bin/bash
set -Eeu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly SCRIPT_DIR
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/colored_echo.sh
# shellcheck disable=SC1091
. "$SCRIPT_DIR"/tools/container_engine.sh

CONTAINER_ENGINE=$(detect_container_engine)
readonly CONTAINER_ENGINE

IMAGE_NAME=ghcr.io/shakiyam/phpcs
readonly IMAGE_NAME

if [[ $CONTAINER_ENGINE == docker ]]; then
  ENGINE_OPTS=(-u "$(id -u):$(id -g)")
else
  ENGINE_OPTS=(--security-opt label=disable)
fi
readonly ENGINE_OPTS

WORK_DIR=$(mktemp -d)
readonly WORK_DIR
trap 'rm -rf "$WORK_DIR"' EXIT

cat >"$WORK_DIR"/bad.php <<'EOF'
<?php
if(true){echo "hello";}
EOF

if OUTPUT=$($CONTAINER_ENGINE container run \
  --name "test_phpcs_$(uuidgen | head -c8)" \
  --rm \
  --pull=never \
  "${ENGINE_OPTS[@]}" \
  -v "$WORK_DIR":/work:ro \
  "$IMAGE_NAME" --standard=PSR12 bad.php); then
  echo_error 'Test failed: phpcs exited with a zero status despite violations.'
  exit 1
fi

if ! grep -q 'FOUND [0-9]* ERROR' <<<"$OUTPUT"; then
  echo_error 'Test failed: phpcs did not report the expected violations.'
  echo "$OUTPUT"
  exit 1
fi

echo_success 'Test passed: phpcs detected coding standard violations successfully.'
