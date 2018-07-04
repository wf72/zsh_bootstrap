#!/usr/bin/env bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

# install zsh
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # If available, use LSB to identify distribution
    if [ -f /etc/lsb-release -o -d /etc/lsb-release.d ]; then
        export DISTRO=$(lsb_release -i | cut -d: -f2 | sed s/'^\t'//)
    # Otherwise, use release info file
    else
        export DISTRO=$(ls -d /etc/[A-Za-z]*[_-][rv]e[lr]* | grep -v "lsb" | cut -d'/' -f3 | cut -d'-' -f1 | cut -d'_' -f1)
    fi
fi
# For everything else (or if above failed), just use generic identifier
[ "$DISTRO" == "" ] && export DISTRO=$UNAME
unset UNAME

if [ "$DISTRO" == "Ubuntu" ]; then
	sudo apt update
	sudo apt -y install zsh wget git tmux
fi

if [ "$DISTRO" == "freebsd" ]; then
	sudo pkg install -y zsh wget git tmux
fi
unset DISTRO

cd $HOME

# install oh-my-zsh. source https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh

  # Only enable exit-on-error after the non-critical colorization stuff,
  # which may fail on systems lacking tput or terminfo
  set -e

  CHECK_ZSH_INSTALLED=$(grep /zsh$ /etc/shells | wc -l)
  if [ ! $CHECK_ZSH_INSTALLED -ge 1 ]; then
    printf "Zsh is not installed! Please install zsh first!\n"
    exit
  fi
  unset CHECK_ZSH_INSTALLED

  if [ ! -n "$ZSH" ]; then
    ZSH=~/.oh-my-zsh
  fi

  if [ -d "$ZSH" ]; then
    printf "You already have Oh My Zsh installed.\n"
    printf "You'll need to remove $ZSH if you want to re-install.\n"
    exit
  fi

  env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git $ZSH || {
    printf "Error: git clone of oh-my-zsh repo failed\n"
    exit 1
  }

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [ "$TEST_CURRENT_SHELL" != "zsh" ]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    if hash chsh >/dev/null 2>&1; then
      printf "Time to change your default shell to zsh!\n"
      chsh -s $(grep /zsh$ /etc/shells | tail -1)
    # Else, suggest the user do so manually.
    else
      printf "I can't change your shell automatically because this system does not have chsh.\n"
      printf "Please manually change your default shell to zsh!\n"
    fi
  fi

# install autosuggestions
if [ ! -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

cd $BASEDIR

# replace home dir in our config
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
	mv ~/.zshrc ~/.zshrc.bak;
fi
cat $BASEDIR/zshrc | sed "s,HOME_DIR,$HOME," > ~/.zshrc

if [ -f ~/.tmux.conf ] || [ -h ~/.tmux.conf ]; then
	mv ~/.tmux.conf ~/.tmux.conf.bak;
fi
cp $BASEDIR/tmux.conf ~/.tmux.conf

currentver="$(tmux -V | cut -f2 -d" ")"
requiredver="2.1"
 if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
        echo "set -g mouse on" >> ~/.tmux.conf
 else
        echo "setw -g mode-mouse on" >> ~/.tmux.conf
        echo "set -g mouse-select-pane on" >> ~/.tmux.conf
        echo "set -g mouse-resize-pane on" >> ~/.tmux.conf
        echo "set -g mouse-select-window on" >> ~/.tmux.conf
 fi
unset currentver
unset requiredver
echo "run '~/.tmux/plugins/tpm/tpm'" >> ~/.tmux.conf

#install tmux tpm
mkdir -p ~/.tmux/plugins/
if [ ! -d ~/.tmux/plugins/tpm ]; then
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
# start a server but don't attach to it
tmux start-server
# create a new session but don't attach to it either
tmux new-session -d
# install the plugins
~/.tmux/plugins/tpm/scripts/install_plugins.sh
# killing the server is not required, I guess
tmux kill-server

#import bash history to zsh
if which ruby; then
	ruby ./bash_to_zsh_history.rb
	exit
elif which python; then
	python ./bash_to_zsh_history.py
fi

unset SCRIPT
unset BASEDIR
unset ZSH_CUSTOM