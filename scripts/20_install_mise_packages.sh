#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

main() {
  source "/usr/bin/lib/sh/log.sh"
  install_mise_packages
  cleanup
}

install_mise_packages() {
  log "20_install_mise_packages.sh" "blue"

  # Mise is installed in the docker file from it's master docker branch.
  log "Configuring mise" "green"
  export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin/:$PATH"

  log "Mise version" "green"
  mise version

  log "Trusting configuration files" "green"
  mise trust "$HOME/.config/mise/config.toml"

  log "Installing tools with mise" "green"
  mise install --yes
}

cleanup() {
  echo ""
  log "Deleting files from /tmp" "green"
  sudo rm -rf /tmp/*

  log "Cleaning go caches" "green"
  go clean -cache
  go clean -testcache
  go clean -fuzzcache
  go clean -modcache

  log "Deleting all .git directories." "green"
  find / -path /proc -prune -o -type d -name ".git" -not -path '/.git' -exec rm -rf {} + 2>/dev/null || true

  log "Clearing mise cache." "green"
  mise cache clear

  log "Deleting go cache files" "green"
  sudo rm -rf /home/vscode/.cache/go-build/trim.txt
  sudo rm -rf /home/vscode/.cache/go-build/testexpire.txt
  sudo rm -rf /home/vscode/.config/go/telemetry/*
  sudo rm -rf /home/vscode/go/pkg/sumdb/sum.golang.org/latest

  log "Deleting all data in /var/log" "green"
  sudo rm -rf /var/log/*

  log "Delete Python cache files" "green"
  sudo find / -name "__pycache__" -type d -exec rm -r {} + 2>/dev/null || true
  sudo find / -name "*.pyc" -exec rm -f {} + 2>/dev/null || true
}

# Run main
if ! (return 0 2>/dev/null); then
  (main "$@")
fi
