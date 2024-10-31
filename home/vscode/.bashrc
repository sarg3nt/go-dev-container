#!/bin/bash
# .bashrc

# cSpell:ignore krew, zshell, CWORD, tldr, tealdeermusl

# Source global definitions
if [ -f /etc/bashrc ]; then
  . /etc/bashrc
fi

# User specific environment
# shellcheck disable=SC2076
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
  PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
  for rc in ~/.bashrc.d/*; do
    if [ -f "$rc" ]; then
      # shellcheck source=/dev/null
      . "$rc"
    fi
  done
fi

unset rc
export PROMPT_DIRTRIM=4

##### Begin User Modifications
# Set up bash history to work with the passed in Docker volume
export PROMPT_COMMAND='history -a' &&
  export HISTFILE=/commandhistory/.bash_history
export PATH="${HOME}/.local:${HOME}/.local/bin:${HOME}/.local/share:$HOME/.local/share/mise/shims:$HOME/bin:${PATH}"

export EDITOR="nano"

# List files colors and aliases
export LS_COLORS=$LS_COLORS:"ow=0;32:"
alias ls='lsd'
alias ll='ls -alh'
alias la='ls -A'

# Docker
alias d="docker"

# Kubernetes
alias k="k9s"
alias kc="kubectl"
alias kga="kubectl_get_all"
alias kx="kubectx"
alias kn="kubens"
alias h="helm"

# shellcheck source=/dev/null
source <(kubectl completion bash)
complete -o default -F __start_kubectl k

# kx and kn
_kube_contexts() {
  local current_arg
  current_arg=${COMP_WORDS[COMP_CWORD]}
  # shellcheck disable=SC2207
  COMPREPLY=($(compgen -W "- $(kubectl config get-contexts --output='name')" -- "$current_arg"))
}
_kube_namespaces() {
  local current_arg
  current_arg=${COMP_WORDS[COMP_CWORD]}
  # shellcheck disable=SC2207
  COMPREPLY=($(compgen -W "- $(kubectl get namespaces -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}')" -- "$current_arg"))
}

complete -F _kube_contexts kx
complete -F _kube_namespaces kn

# shellcheck source=/dev/null
source <(helm completion bash)
complete -F __start_helm h
complete -F __start_helm helm

# Starship
eval "$(starship init bash)"

# Utils
alias help="/usr/local/bin/help"
alias g=git

# Run fzf
# shellcheck source=/dev/null
[ -f ~/.fzf.bash ] && source ~/.fzf.bash

# Active mise
eval "$(/usr/local/bin/mise activate bash)"
mise trust --all
mise install --yes

# Run help screen on shell start.
help
