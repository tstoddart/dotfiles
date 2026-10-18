# ==============================================================================
# Cross-Platform ZSH Configuration (macOS & Linux)
# ==============================================================================

# Homebrew environment setup
if [[ "$OSTYPE" == darwin* ]]; then
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
  export HOMEBREW_NO_ENV_HINTS="true"
  [[ -d "$HOMEBREW_PREFIX/share/zsh/site-functions" ]] && FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
elif [[ -x /home/linuxbrew/.linuxbrew/bin/brew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
fi

# General environment & paths
export PATH="${HOME}/.local/bin:${HOME}/.cargo/bin:${PATH}"
fpath=(${HOME}/.zfunc $fpath)
export EDITOR="nvim"
alias vim='nvim'
alias ls='eza'

[[ "$TERM" = "xterm-kitty" ]] && alias ssh="kitty +kitten ssh"

# Atuin shell history sync
if (( $+commands[atuin] )); then
  eval "$(atuin init zsh)"
fi

# macOS specific integrations
if [[ "$OSTYPE" == darwin* ]]; then
  # SSH Certificate Agent (SSHCE / Secretive)
  if [[ -S /Users/tom/Library/Containers/org.hejki.osx.sshce.agent/Data/socket.ssh ]]; then
    export SSH_AUTH_SOCK=/Users/tom/Library/Containers/org.hejki.osx.sshce.agent/Data/socket.ssh
  fi

  alias ofzf='open "$(fzf)"'

  # Bitwarden CLI helper
  bwcopy() {
    if (( $+commands[bw] )); then
      local copy_cmd="pbcopy"
      (( $+commands[pbcopy-secure] )) && copy_cmd="pbcopy-secure"
      bw get item "$(bw list items | jq '.[] | "\(.name) | username: \(.login.username) | id: \(.id)" ' | fzf-tmux | awk '{print $(NF -0)}' | sed 's/\"//g')" | jq '.login.password' | sed 's/\"//g' | $copy_cmd
    fi
  }
fi

# Completion styling
zmodload zsh/complist
zstyle ':completion:*' menu select
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ------------------------------------------------------------------------------
# Zim Framework Configuration
# ------------------------------------------------------------------------------

# History options
setopt HIST_IGNORE_ALL_DUPS

# Keybindings: Emacs mode
bindkey -e
WORDCHARS=${WORDCHARS//[\/]}

# Zim module settings
ZSH_AUTOSUGGEST_MANUAL_REBIND=1
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# Initialize Zim modules
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Download zimfw plugin manager if missing
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p ${ZIM_HOME} && wget -nv -O ${ZIM_HOME}/zimfw.zsh \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init
fi

# Initialize modules
source ${ZIM_HOME}/init.zsh

# Completion module preferences and fzf-tab styling
zmodload zsh/complist
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Disable default completion menu to let fzf-tab take over
zstyle ':completion:*' menu no

# fzf-tab navigation & settings
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' switch-group ',' '.'
zstyle ':fzf-tab:*' prefix ''

# Directory completion preview with eza and Nerd Font icons
zstyle ':fzf-tab:complete:(cd|zd):*' fzf-preview 'eza -1 --color=always --icons=always --group-directories-first $realpath'

# Live preview for files (bat) and directories (eza) across all completions
zstyle ':fzf-tab:complete:*' fzf-preview 'if [[ -d $realpath ]]; then eza -1 --color=always --icons=always --group-directories-first $realpath; else bat --style=numbers --color=always --line-range :50 $realpath 2>/dev/null; fi'

# Keybindings for zsh-history-substring-search
zmodload -F zsh/terminfo +p:terminfo
for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key

# ------------------------------------------------------------------------------
# Tool Integrations & Aliases
# ------------------------------------------------------------------------------

autoload -Uz zcalc

# Pipx completion
if (( $+commands[register-python-argcomplete] && $+functions[compdef] )); then
  eval "$(register-python-argcomplete pipx)"
fi

# FZF shell integrations (if installed)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Antigravity config sync with homelab
alias agy-push='rsync -avz --exclude=".migrated" ~/.gemini/config/ homelab:~/.gemini/config/'
alias agy-pull='rsync -avz --exclude=".migrated" homelab:~/.gemini/config/ ~/.gemini/config/'

# Dotfiles management (bare git repository with home worktree)
alias dotfiles='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'

# ------------------------------------------------------------------------------
# Machine-Local Overrides & Secrets (untracked by git)
# ------------------------------------------------------------------------------
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
# >>> zerobrew >>>
# zerobrew
export ZEROBREW_DIR='/home/tom/.zerobrew'
export ZEROBREW_BIN='/home/tom/.zerobrew/bin'
export ZEROBREW_ROOT='/home/tom/.local/share/zerobrew'
export ZEROBREW_PREFIX='/home/tom/.local/share/zerobrew/prefix'
export PKG_CONFIG_PATH="$ZEROBREW_PREFIX/lib/pkgconfig:${PKG_CONFIG_PATH:-}"

# SSL/TLS certificates (only if ca-certificates is installed)
if [ -z "${CURL_CA_BUNDLE:-}" ] || [ -z "${SSL_CERT_FILE:-}" ]; then
  if [ -f "$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/opt/ca-certificates/share/ca-certificates/cacert.pem"
  elif [ -f "$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/etc/ca-certificates/cacert.pem"
  elif [ -f "$ZEROBREW_PREFIX/etc/openssl/cert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/etc/openssl/cert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/etc/openssl/cert.pem"
  elif [ -f "$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem" ]; then
    [ -z "${CURL_CA_BUNDLE:-}" ] && export CURL_CA_BUNDLE="$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem"
    [ -z "${SSL_CERT_FILE:-}" ] && export SSL_CERT_FILE="$ZEROBREW_PREFIX/share/ca-certificates/cacert.pem"
  fi
fi

if [ -z "${SSL_CERT_DIR:-}" ]; then
  if [ -d "$ZEROBREW_PREFIX/etc/ca-certificates" ]; then
    export SSL_CERT_DIR="$ZEROBREW_PREFIX/etc/ca-certificates"
  elif [ -d "$ZEROBREW_PREFIX/etc/openssl/certs" ]; then
    export SSL_CERT_DIR="$ZEROBREW_PREFIX/etc/openssl/certs"
  elif [ -d "$ZEROBREW_PREFIX/share/ca-certificates" ]; then
    export SSL_CERT_DIR="$ZEROBREW_PREFIX/share/ca-certificates"
  fi
fi

# Helper function to safely append to PATH
_zb_path_append() {
    local argpath="$1"
    case ":${PATH}:" in
        *:"$argpath":*) ;;
        *) export PATH="$argpath:$PATH" ;;
    esac;
}

_zb_path_append "$ZEROBREW_BIN"
_zb_path_append "$ZEROBREW_PREFIX/sbin"
_zb_path_append "$ZEROBREW_PREFIX/bin"

# <<< zerobrew <<<
