export ZSH=HOME_DIR/.oh-my-zsh

#ZSH_THEME="dieter"
ZSH_THEME="fino-time"
#ZSH_THEME="rkj-repos"


ZSH_TMUX_AUTOSTART=false
ZSH_TMUX_AUTOCONNECT=false

plugins=(
  git
  zsh-autosuggestions
  command-not-found
  common-aliases
  docker
  pip
  python
  pyenv
  sudo
  systemd
  tmux
  nmap
  rsync
  ubuntu
  ansible
  docker-compose
  vagrant
  vagrant-prompt
)

source $ZSH/oh-my-zsh.sh

# disabled, delete in future
#local user="%(!.%{$fg[cyan]%}.%{$fg[cyan]%})%n%{$reset_color%}"
#local pwd="%{$fg[cyan]%}%~%{$reset_color%}"
#PROMPT='${time} ${user}${host} ${pwd} $(git_prompt_info)> '

COMPLETION_WAITING_DOTS="true"

# molecule autocomplit
#eval "$(_MOLECULE_COMPLETE=SHELL_source molecule)"

export HISTSIZE=32768;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

# install exa for pretty ls and uncoment this string
alias ls='exa'
alias lst='exa -T'
alias l='exa -lFh' 
alias la='exa -laFh'
alias ll='exa -l'


# create new session
# example usage:
# tmux-new -s NAME_OF_SESSION
# https://superuser.com/questions/821339/start-a-new-session-from-within-tmux-with-zsh-tmux-autostart-true
tmux-new() {
  if [[ -n $TMUX ]]; then
    tmux switch-client -t "$(TMUX= tmux -S "${TMUX%,*,*}" new-session -dP "$@")"
  else
    tmux new-session "$@"
  fi
}

export TERM="xterm-256color"

declare TMUX
MOTD="/var/run/motd.dynamic"
ISSUE="/etc/issue"

if [ ! -z "$TMUX" ]; then
      if [ -f "$MOTD" ]; then
            cat "$MOTD"
      elif [ -f "$ISSUE" ]; then
            cat "$ISSUE"
      else
:
      fi
fi
