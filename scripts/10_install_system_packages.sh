#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# cSpell:ignore epel socat CONFIGUREZSHASDEFAULTSHELL

# Install system packages
main() {
  source "/usr/bin/lib/sh/log.sh"
  install_system_packages
  install_devcontainer_features
  cleanup
}

install_system_packages() {
  log "10_install_system_packages.sh" "blue"

  log "Adding install_weak_deps=False to /etc/dnf/dnf.conf" "green"
  echo "install_weak_deps=False" >>/etc/dnf/dnf.conf
  echo "keepcache=0" >>/etc/dnf/dnf.conf

  log "Installing epel release" "green"
  dnf install -y epel-release && dnf clean all

  log "Installing dnf plugins core" "green"
  dnf install -y dnf-plugins-core

  log "Adding docker ce repo" "green"
  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

  log "Running dnf upgrade" "green"
  dnf upgrade -y

  log "Installing bash completion" "green"
  dnf install -y bash-completion

  log "Installing sudo" "green"
  dnf install -y sudo

  log "Installing ca-certificates" "green"
  dnf install -y ca-certificates

  log "Installin docker-ce-cli" "green"
  dnf install -y docker-ce-cli

  log "Installing docker-buildx-plugin" "green"
  dnf install -y docker-buildx-plugin

  log "Installing git" "green"
  dnf install -y git

  log "Installing gnupg2" "green"
  dnf install -y gnupg2

  log "Installing jq" "green"
  dnf install -y jq

  log "Install make" "green"
  dnf install -y make

  log "Installing sshpass" "green"
  dnf install -y sshpass

  log "Installing socat" "green"
  dnf install -y socat

  log "Installing util-linux-user" "green"
  dnf install -y util-linux-user

  log "Installing xz zip unzip" "green"
  dnf install -y xz zip unzip
}

install_devcontainer_features() {
  log "Installing dev container features" "blue"
  log "Exporting dev container features install.sh config variables." "green"
  export CONFIGUREZSHASDEFAULTSHELL=true
  export INSTALL_OH_MY_ZSH=true
  export UPGRADEPACKAGES=false

  log "Making /tmp/source directory" "green"
  mkdir /tmp/source
  cd /tmp/source

  log "Cloning devcontainers features repository" "green"
  git clone --depth 1 -- https://github.com/devcontainers/features.git

  log "Running install script" "green"
  cd /tmp/source/features/src/common-utils/
  ./install.sh
  cd -
}

cleanup() {
  #dnf -y remove epel-release
  #dnf -y remove dnf-plugins-core

  echo ""
  log "Deleting files from /tmp" "green"
  sudo rm -rf /tmp/*

  log "Deleting all .git directories." "green"
  find / -path /proc -prune -o -type d -name ".git" -not -path '/.git' -exec rm -rf {} + 2>/dev/null || true

  log "Running dnf autoremove" "green"
  sudo dnf autoremove -y

  log "Running dnf clean all" "green"
  sudo dnf clean all

  log "Deleting /etc/machine-id." "green"
  sudo rm -rf /etc/machine-id

  log "Deleting /etc/pki/ca-trust/extracted/java/cacerts." "green"
  sudo rm -rf /etc/pki/ca-trust/extracted/java/cacerts

  log "Deleting /var/cache/ldconfig/aux-cache" "green"
  sudo rm -rf /var/cache/ldconfig/aux-cache

  log "Deleting dnf data" "green"
  sudo rm -rf /var/lib/dnf/repos/*
  sudo rm -rf /var/lib/dnf/history.sqlite-shm
  sudo rm -rf /var/lib/dnf/history.sqlite
  sudo rm -rf /var/lib/dnf/history.sqlite-wal

  log "Cleaning RPM database files" "green"
  sudo rm -f /var/lib/rpm/*
  #sudo rm -f /var/lib/rpm/__db.*
  #sudo rm -f /var/lib/rpm/Packages
  #sudo rm -f /var/lib/rpm/rpmdb.sqlite 2>/dev/null || true
  sudo rpm --initdb

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
