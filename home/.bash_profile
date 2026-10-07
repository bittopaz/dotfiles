#!/usr/bin/env bash

# Locale
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Editor
export EDITOR=vim

# PATH helpers. These keep PATH edits idempotent, even if this file is sourced
# more than once in the same shell.
path_remove() {
  local dir="$1" old_ifs="$IFS" part new_path=""
  IFS=:
  for part in $PATH; do
    [[ -n "$part" && "$part" != "$dir" ]] || continue
    new_path="${new_path:+$new_path:}$part"
  done
  IFS="$old_ifs"
  PATH="$new_path"
}

path_prepend() {
  [[ -d "$1" ]] || return
  path_remove "$1"
  PATH="$1${PATH:+:$PATH}"
}

path_append() {
  [[ -d "$1" ]] || return
  path_remove "$1"
  PATH="${PATH:+$PATH:}$1"
}

# Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
export HOMEBREW_REPOSITORY="/opt/homebrew"
path_prepend "/opt/homebrew/sbin"
path_prepend "/opt/homebrew/bin"
case ":${MANPATH:-}:" in
  *":/opt/homebrew/share/man:"*) ;;
  *) MANPATH="/opt/homebrew/share/man${MANPATH:+:$MANPATH}" ;;
esac
case "$MANPATH" in *:) ;; *) MANPATH="$MANPATH:" ;; esac
export MANPATH
case ":${INFOPATH:-}:" in
  *":/opt/homebrew/share/info:"*) ;;
  *) INFOPATH="/opt/homebrew/share/info${INFOPATH:+:$INFOPATH}" ;;
esac
case "$INFOPATH" in *:) ;; *) INFOPATH="$INFOPATH:" ;; esac
export INFOPATH

# GNU grep
path_prepend "/opt/homebrew/opt/grep/libexec/gnubin"

# User-local and machine-local bins
path_prepend "/opt/bin"
path_prepend "$HOME/.local/bin"

# Golang
export GOPATH="$HOME/go"
path_append "$GOPATH/bin"

# Doom Emacs
path_append "$HOME/.config/emacs/bin"

# https://pi.dev
export PI_SKIP_VERSION_CHECK=1
export PI_MARKDOWN_PREVIEW_DEVICE_SCALE_FACTOR=1

# Lumen Pi extension: disable automatic post-turn diff review.
# Manual /lumen-diff still works.
# Source: https://github.com/jnsahaj/lumen/blob/e4ba4e508710379ab812acf7fe75f4415b9d6988/integrations/pi/extension/README.md#config
export LUMEN_AUTO_REVIEW=0

# Configure 4 spaces when using xmllint
export XMLLINT_INDENT="    "

# Optional snippets, loaded in filename order. Keep them safe to source twice
# (interactive login shells read both startup files); guard interactive-only code.
for bash_config in "$HOME/.config/bash/conf.d/"*.sh; do
  # shellcheck disable=SC1090
  [[ -f "$bash_config" ]] && source "$bash_config"
done
unset bash_config

# Private secrets. Keep this file chmod 600.
[[ -f "$HOME/.bash_secrets" ]] && source "$HOME/.bash_secrets"

# Make global mise tools available to login/non-interactive bash processes.
# Interactive shells upgrade this to full dynamic activation in ~/.bashrc.
# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate bash --shims)"
# <<< mise:activate <<<

export PATH
unset -f path_remove path_prepend path_append

# Interactive bash config: aliases, prompt, readline bindings, shell functions,
# and interactive tool hooks live in ~/.bashrc.
case $- in
  *i*) [[ -f "$HOME/.bashrc" ]] && source "$HOME/.bashrc" ;;
esac

# Google Workspace CLI credentials
# Let gws use credentials saved by `gws auth login`, not a stale exported file.

# >>> fabric >>>
# Managed by Fabric (v1). Edits inside this block may be overwritten.
# Remove with `fabric path disable`, or just delete this block.
[ -x "$HOME/.fabric/bin/fabric" ] && export PATH="$HOME/.fabric/bin:$PATH"
# <<< fabric <<<
