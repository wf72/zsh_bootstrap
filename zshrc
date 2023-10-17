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
  nmap
  rsync
  ubuntu
  ansible
  docker-compose
  vagrant
  vagrant-prompt
  zsh-syntax-highlighting
  ssh-agent
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

eval "$(BREWPATH_REPLACE shellenv)"

# batcat alias
alias cat='bat'

# brew completions
if type brew &>/dev/null
then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

  autoload -Uz compinit
  compinit
fi

# macos zsh-autosuggestions accept word on "option + f"
bindkey 'ƒ' forward-word
