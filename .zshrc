export ZSH={{HOME_DIR}}/.oh-my-zsh

ZSH_TMUX_AUTOSTART=true
ZSH_TMUX_AUTOCONNECT=true

plugins=(
  git
  zsh-autosuggestions
  debian
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
