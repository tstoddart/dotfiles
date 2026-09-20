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

# Completion styling & fzf-tab
zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# Nicer preview for cd in fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:*' switch-group '<' '>'

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
