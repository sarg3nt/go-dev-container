#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# cSpell:ignore epel socat

# Install system packages
main() {
  source "/usr/bin/lib/sh/log.sh"
  log "10_install_system_packages.sh" "blue"

  log "Adding install_weak_deps=False to /etc/dnf/dnf.conf" "green"
  echo "install_weak_deps=False" >>/etc/dnf/dnf.conf

  log "Installing epel release" "green"
  dnf install -y epel-release && dnf clean all

  log "Installing dnf plugins core" "green"
  dnf install -y dnf-plugins-core

  log "Running /usr/bin/crb enable" "green"
  /usr/bin/crb enable

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

  log "Installing dev containers features" "green"
  log "Exporting zshell variables" "green"
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

  dnf -y remove epel-release
  dnf -y remove dnf-plugins-core

  log "Running dnf autoremove" "green"
  dnf autoremove -y

  log "Running dnf clean all" "green"
  dnf clean all

  log "Deleting files from /tmp" "green"
  rm -rf /tmp/*
}

# Run main
if ! (return 0 2>/dev/null); then
  (main "$@")
fi
