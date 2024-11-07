#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  source "/usr/bin/lib/sh/log.sh"

  ############ Install mise
  log "20_install_mise_packages.sh" "blue"

  # Mise is installed in the docker file from it's master docker branch.
  log "Configuring mise" "green"
  export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin/:$PATH"

  if [[ -n "${GITHUB_API_TOKEN:-}" ]]; then
    log "GITHUB_API_TOKEN found" "green"
  else
    log "GITHUB_API_TOKEN not found" "yellow"
  fi

  log "Mise version" "green"
  mise version

  log "Trusting configuration files" "green"
  mise trust "$HOME/.config/mise/config.toml"
  mise trust --all

  log "Installing tools with mise" "green"
  mise install --yes

  log "Deleting files from /tmp" "green"
  sudo rm -rf /tmp/*
}

# Run main
if ! (return 0 2>/dev/null); then
  (main "$@")
fi
