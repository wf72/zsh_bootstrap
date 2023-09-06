#!/usr/bin/env bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

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

zsh $ZSH/tools/upgrade.sh

cd $BASEDIR

git pull

# replace home dir in our config
if [ -f ~/.zshrc ] || [ -h ~/.zshrc ]; then
	mv ~/.zshrc ~/.zshrc.bak;
fi
cat $BASEDIR/zshrc | sed "s,HOME_DIR,$HOME," > ~/.zshrc

# vimrc install
if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
	mv ~/.vimrc ~/.vimrc.bak;
fi

cp $BASEDIR/.vimrc ~/.vimrc

# TMUX configure
currentver="$(tmux -V | cut -f2 -d" ")"
requiredver="2.9"
 if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
    if [ -f ~/.tmux.conf ] || [ -h ~/.tmux.conf ]; then
      mv ~/.tmux.conf ~/.tmux.conf.bak;
    fi
    cp $BASEDIR/tmux_29.conf ~/.tmux.conf
 else
    if [ -f ~/.tmux.conf ] || [ -h ~/.tmux.conf ]; then
      mv ~/.tmux.conf ~/.tmux.conf.bak;
    fi
    cp $BASEDIR/tmux.conf ~/.tmux.conf
 fi
requiredver="2.1"
 if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
        echo "set -g mouse on" >> ~/.tmux.conf
 else
        echo "setw -g mode-mouse on" >> ~/.tmux.conf
        echo "set -g mouse-select-pane on" >> ~/.tmux.conf
        echo "set -g mouse-resize-pane on" >> ~/.tmux.conf
        echo "set -g mouse-select-window on" >> ~/.tmux.conf
 fi

if [ ! -d ~/.tmux/plugins/tpm ]; then
	cd ~/.tmux/plugins/tpm
	git pull
	cd -
fi

if [ -n "$TMUX" ]; then
	# install the plugins
	tmux source ~/.tmux.conf
	~/.tmux/plugins/tpm/scripts/install_plugins.sh
	tmux source ~/.tmux.conf
else
	# start a server but don't attach to it
	tmux start-server
	# create a new session but don't attach to it either
	tmux new-session -d
	tmux source ~/.tmux.conf
	# install the plugins
	~/.tmux/plugins/tpm/scripts/install_plugins.sh
	# killing the server is not required, I guess
	tmux kill-server
fi

# install vim-plug
if [ ! -f ~/.vim/autoload/plug.vim ]; then
 curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim +PlugInstall +qall


unset SCRIPT
unset BASEDIR
unset ZSH_CUSTOM
