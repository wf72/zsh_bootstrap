export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="fino-time"

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
  zsh-syntax-highlighting
  ssh-agent
  $k8s_plugins
)

source $ZSH/oh-my-zsh.sh

# kubectx & kubens
autoload -U compinit && compinit
alias kctx='kubectx'
alias kns='kubens'

COMPLETION_WAITING_DOTS="true"

KUBE_PS1_PREFIX=''
KUBE_PS1_SUFFIX=''
KUBE_PS1_SYMBOL_USE_IMG=true
KUBE_PS1_SEPARATOR=''
KUBE_PS1_CTX_COLOR=green

PROMPT="╭─%{$FG[040]%}%n%{$reset_color%} %{$FG[239]%}at%{$reset_color%} %{$FG[033]%}$(box_name)%{$reset_color%} "'$(kube_ps1)'" %{$FG[239]%}in%{$reset_color%} %{$terminfo[bold]$FG[226]%}%~%{$reset_color%}\$(git_prompt_info)\$(ruby_prompt_info) %D - %*
╰─\$(virtualenv_info)\$(prompt_char) "

# molecule autocomplit
#eval "$(_MOLECULE_COMPLETE=SHELL_source molecule)"

export HISTSIZE=3276800;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";
export EDITOR=/usr/bin/vim
export VISUAL=/usr/bin/vim

export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# kubecolor
alias kubectl=kubecolor
compdef kubecolor=kubectl

eval "$($brewpath shellenv)"

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

# HSTR configuration
alias hh=hstr                    # hh to be alias for hstr
setopt histignorespace           # skip cmds w/ leading space from history
export HSTR_CONFIG=hicolor       # get more colors
hstr_no_tiocsti() {
    zle -I
    { HSTR_OUT="$( { </dev/tty hstr ${BUFFER}; } 2>&1 1>&3 3>&- )"; } 3>&1;
    BUFFER="${HSTR_OUT}"
    CURSOR=${#BUFFER}
    zle redisplay
}
zle -N hstr_no_tiocsti
bindkey '\C-r' hstr_no_tiocsti
export HSTR_TIOCSTI=n


$ezaaliases
