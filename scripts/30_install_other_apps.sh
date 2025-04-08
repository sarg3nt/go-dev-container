#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# cSpell:ignore kubectx kubens mvdan gofumpt FUMPT gopls

main() {
  source "/usr/bin/lib/sh/log.sh"
  export PATH="$HOME/.local/share/mise/shims:$HOME/.local/bin/:$PATH"

  log "30_install_other_apps.sh" "blue"

  add_go_tools
  add_vscode_extensions_cache
  add_bash_history_cache
  add_fzf_completions_files
  install_kubectx_kubens_completions
  install_omz_plugins
  cleanup
  date +"%B %d %Y" >/home/vscode/build_date.txt
}

add_go_tools() {
  log "Adding Go Tools" "green"
  go install "github.com/go-delve/delve/cmd/dlv@latest"
  go install "mvdan.cc/gofumpt@latest"
  go install golang.org/x/tools/gopls@latest
}

add_vscode_extensions_cache() {
  log "Adding VSCode Extensions Cache Support" "green"
  mkdir -p "/home/${USERNAME}/.vscode-server/extensions"
  chown -R "${USERNAME}" "/home/${USERNAME}/.vscode-server"
}

add_bash_history_cache() {
  log "Adding Bash History Cache Support" "blue"
  sudo mkdir /commandhistory
  sudo touch /commandhistory/.bash_history
  sudo chown -R "$USERNAME" "/commandhistory"
}

add_fzf_completions_files() {
  log "Adding FZF Completions Files" "green"
  curl -sL https://raw.githubusercontent.com/junegunn/fzf/master/shell/key-bindings.zsh --output "$HOME/.fzf-key-bindings.zsh"
  curl -sL https://raw.githubusercontent.com/junegunn/fzf/master/shell/completion.zsh --output "$HOME/.fzf-completion.zsh"
}

install_kubectx_kubens_completions() {
  log "Installing kubectx and kubens completions" "green"
  mkdir -p "$HOME/.oh-my-zsh/custom/completions"
  chmod -R 755 "$HOME/.oh-my-zsh/custom/completions"

  log "Installing kubectx completions" "green"
  curl -sL https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_kubectx.zsh --output "$HOME/.oh-my-zsh/custom/completions/_kubectx.zsh"
  log "Installing kubens completions" "green"
  curl -sL https://raw.githubusercontent.com/ahmetb/kubectx/master/completion/_kubens.zsh --output "$HOME/.oh-my-zsh/custom/completions/_kubens.zsh"
}

install_omz_plugins() {
  log "Installing Oh My ZSH plugins" "green"
  git clone --depth 1 -- https://github.com/zsh-users/zsh-autosuggestions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"
  git clone --depth 1 -- https://github.com/zdharma-continuum/fast-syntax-highlighting.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting"
  # https://github.com/marlonrichert/zsh-autocomplete/issues/797
  git clone --branch "24.09.04" --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autocomplete"
  git clone --depth 1 -- https://github.com/zsh-users/zsh-completions.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"
}

cleanup() {
  log "Running cleanup" "blue"
  log "Deleting files from /tmp" "green"
  sudo rm -rfv /tmp/*
  echo ""

  log "Cleaning go caches" "green"
  go clean -cache
  go clean -testcache
  go clean -fuzzcache
  go clean -modcache
  echo ""

  log "Deleting all .git directories." "green"
  find / -path /proc -prune -o -type d -name ".git" -not -path '/.git' -exec rm -rfv {} + 2>/dev/null || true
  echo ""

  log "Clearing mise cache." "green"
  mise cache clear
  echo ""

  log "Deleting go cache files" "green"
  sudo rm -rfv /home/vscode/.cache/go-build/trim.txt
  sudo rm -rfv /home/vscode/.cache/go-build/testexpire.txt
  sudo rm -rfv /home/vscode/.config/go/telemetry/*
  sudo rm -rfv /home/vscode/go/pkg/sumdb/sum.golang.org/latest
  echo ""

  log "Deleting all data in /var/log" "green"
  sudo rm -rfv /var/log/*
  echo ""

  log "Delete Python cache files" "green"
  sudo find / -name "__pycache__" -type d -exec rm -rfv {} + 2>/dev/null || true
  sudo find / -name "*.pyc" -exec rm -fv {} + 2>/dev/null || true
}

# Run main
if ! (return 0 2>/dev/null); then
  (main "$@")
fi
