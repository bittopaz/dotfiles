# ~/.bashrc
# shellcheck shell=bash
# Interactive bash configuration.

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

## Aliases
# List directory contents
alias lsa='ls -lah'
alias l='ls -lah'
alias ll='ls -lh'
alias la='ls -lAh'
alias bssh='ssh ssh.booking.com'

# Run `bk auth:login`
bklogin() {
  BK_AUTH_SSO_TIMEOUT=600000 BK_DISABLE_EVENTS=1 bk auth:login --skip-okta-auth "$@" || return

  # Import the refresh token that bk auth:login just wrote to ~/.bkcloud/auth.yaml.
  # BK_TOKEN_NO_LOGIN prevents the cache helper from starting a second browser
  # auth flow if the import unexpectedly fails.
  BK_TOKEN_FORCE_REFRESH=1 BK_TOKEN_NO_LOGIN=1 "$HOME/.pi/agent/scripts/bk-token" >/dev/null || return
  printf 'pi bk token cache refreshed\n'
}

## Better History
# Enable partial history search with up/down arrows.
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Enter a few characters and press CTRL+p/CTRL+n to search backwards/forwards
# through the history.
if [[ ${SHELLOPTS} =~ (vi|emacs) ]]; then
  bind '"\C-p":history-substring-search-backward'
  bind '"\C-n":history-substring-search-forward'
fi

export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=10000
export HISTFILESIZE=20000

# Append to history instead of overwriting it.
shopt -s histappend

## Shell functions
surge_proxy_on() {
  export https_proxy=http://127.0.0.1:6152
  export http_proxy=http://127.0.0.1:6152
  export all_proxy=socks5://127.0.0.1:6153
}

unset_proxy() {
  unset HTTPS_PROXY
  unset HTTP_PROXY
  unset ALL_PROXY
  unset NO_PROXY
  unset https_proxy
  unset http_proxy
  unset all_proxy
  unset no_proxy
}

# sudo() {
#   if [[ $(/usr/sbin/dseditgroup -q -o checkmember -m "$(/usr/bin/stat -f%Su /dev/console)" admin) =~ ^no.+$ ]]; then
#     /Applications/Privileges.app/Contents/Resources/PrivilegesCLI --add &&
#     /usr/bin/sudo "${@}"
#   else
#     /usr/bin/sudo "${@}"
#   fi
# }

mygit() {
  git config user.email bittopaz@gmail.com
  git config commit.gpgsign false
}

# Claude Code shortcuts
cc-in-tooling() {
  cd ~/Developer/gitlab.com/booking-com/mpsre/tooling && claude "$@"
}

cc-in-notes() {
  cd ~/Developer/gitlab.com/booking-com/personal/xiaoyu.zhong/notes/ && claude "$@"
}

pi-in-notes() {
  cd ~/Developer/gitlab.com/booking-com/personal/xiaoyu.zhong/notes/ && pi "$@"
}

# mise, https://mise.jdx.dev
# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate bash)"
# <<< mise:activate <<<

# https://starship.rs/
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# Save new history immediately and read history written by other shells. Add this
# after prompt/tool initializers so it composes with their PROMPT_COMMAND hooks.
__bash_history_sync() {
  history -a
  history -n
}

__bash_add_prompt_command() {
  local cmd="$1" existing

  if [[ "$(declare -p PROMPT_COMMAND 2>/dev/null)" == declare\ -a* ]]; then
    for existing in "${PROMPT_COMMAND[@]}"; do
      [[ "$existing" == "$cmd" ]] && return
    done
    PROMPT_COMMAND+=("$cmd")
  else
    local prompt_command="${PROMPT_COMMAND-}"
    case ";$prompt_command;" in
      *";$cmd;"*) ;;
      *)
        # PROMPT_COMMAND may be either a scalar or an array in modern Bash.
        # This branch is only for the scalar form.
        # shellcheck disable=SC2178
        PROMPT_COMMAND="${prompt_command:+$prompt_command; }$cmd"
        ;;
    esac
  fi
}

__bash_add_prompt_command __bash_history_sync
unset -f __bash_add_prompt_command

# bpages CLI
export PATH="$HOME/.bpages/bin:$PATH"

# Launch Codex with the preferred model and reasoning effort.
cx() {
  command codex --model gpt-5.6-sol \
    -c 'model_reasoning_effort="xhigh"' "$@"
}
