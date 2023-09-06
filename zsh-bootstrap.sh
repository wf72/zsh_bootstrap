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
	sudo apt -y install zsh wget git exa curl
fi

if [[ "$DISTRO" == *"redhat"* ]]; then
	sudo dnf install -y zsh wget git exa curl sqlite
fi
unset DISTRO

cd $HOME

### install oh_my_zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/ohmyzshinstall.sh
sed -i "s/exec zsh -l//" /tmp/ohmyzshinstall.sh
sh /tmp/ohmyzshinstall.sh
rm /tmp/ohmyzshinstall.sh

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

# vimrc install
if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
	mv ~/.vimrc ~/.vimrc.bak;
fi

cp $BASEDIR/.vimrc ~/.vimrc

# install vim-plug
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim +PlugInsall +qall

# install homebrew https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install spacer
brew tap samwho/spacer
brew install spacer

# install zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# isntall zellij (tmux analog, but more better)
curl -sSL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz -o /tmp/zellij.tar.gz
tar -xzf /tmp/zellij.tar.gz -C /tmp
sudo install -b /tmp/zellij /usr/local/bin
rm -f /tmp/zellij

if [ -f ~/.config/zellij/config.kdl ] || [ -h ~/.config/zellij/config.kdl ]; then
	mv ~/.config/zellij/config.kdl ~/.config/zellij/config.kdl.bak;
fi
cp $BASEDIR/zellig.config.kdl ~/.config/zellij/config.kdl

#import bash history to zsh
if which python3; then
	python3 ./bash_to_zsh_history.py
elif which ruby; then
	ruby ./bash_to_zsh_history.rb
	exit
fi

unset SCRIPT
unset BASEDIR
unset ZSH_CUSTOM
