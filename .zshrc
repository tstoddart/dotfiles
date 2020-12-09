export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

zplug "denysdovhan/spaceship-prompt", use:spaceship.zsh, from:github, as:theme
zplug "sfischer13/zsh-sensible"
#zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zaw"
zplug "zsh-users/zsh-history-substring-search"
zplug "marzocchi/zsh-notify"
zplug "laurenkt/zsh-vimto"
#zplug "marlonrichert/zsh-autocomplete", defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:3

zplug load

# for history substring search plugin
#bindkey '^[[A' history-substring-search-up
#bindkey '^[[B' history-substring-search-down

FPATH="/usr/local/share/zsh/site-functions:$FPATH"

bindkey '^X' zaw
bindkey '^R' zaw-history

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line

source /usr/local/etc/profile.d/autojump.sh

alias ls='exa'
alias ofzf='open "$(fzf)"'

autoload -U zcalc

autoload -U compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' menu select=5
setopt menu_complete

export EDITOR="nvim"

export SSH_AUTH_SOCK=/Users/tom/Library/Containers/org.hejki.osx.sshce.agent/Data/socket.ssh
alias dotfiles="/usr/bin/git --git-dir=$HOME/.dotfiles.git/ --work-tree=$HOME"
