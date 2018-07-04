export ZSH=HOME_DIR/.oh-my-zsh

ZSH_THEME="dieter"

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=true

plugins=(
  git
  zsh-autosuggestions
  command-not-found
  common-aliases
  django
  docker
  knife
  pip
  python
  pyenv
  sudo
  systemd
  tmux
  nmap
  rsync
  ubuntu
)

source $ZSH/oh-my-zsh.sh

local pwd="%{$fg[blue]%}%~%{$reset_color%}"

PROMPT='${time} ${user}${host} ${pwd} $(git_prompt_info)> '

COMPLETION_WAITING_DOTS="true"

export HISTSIZE=32768;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";

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