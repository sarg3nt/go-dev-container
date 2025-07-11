#!/bin/bash
#
# This script will start the dev container outside of VSCode.
#
# cSpell:ignore

set -euo pipefail
IFS=$'\n\t'

main() {
  local tag="$1"
  if [ -z "$tag" ]; then
    tag="latest"
  fi

  # Name of the container
  local container_name="ghcr.io/sarg3nt/go-dev-container:${tag}"

  # User being created in the container
  local container_user="vscode"

  docker run --mount type=bind,source="$(pwd)",target=/workspaces/working \
    -w /workspaces/working -it --rm -u "${container_user}" \
    "${container_name}" zsh

}

if ! (return 0 2>/dev/null); then
  (main "$@")
fi
