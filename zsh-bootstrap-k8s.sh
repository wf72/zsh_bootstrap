#!/usr/bin/env bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
KUBECTL_VERSION=v1.23.4
ARGOCD_VERSION=v2.6.11

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
	sudo apt -y install zsh wget git tmux exa curl
fi

if [ "$DISTRO" == "freebsd" ]; then
	sudo pkg install -y zsh wget git tmux exa curl 
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

cat $BASEDIR/zshrc-k8s | sed "s,HOME_DIR,$HOME," > ~/.zshrc


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
tmux source ~/.tmux.conf
# install the plugins
~/.tmux/plugins/tpm/scripts/install_plugins.sh
# killing the server is not required, I guess
tmux kill-server

# install vim-plug
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim +PlugInsall +qall

# install kubectl
curl -L https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl -o /tmp/kubectl
sudo install -b /tmp/kubectl /usr/bin
rm -f /tmp/kubectl

# install argocd cli
curl -sSL -o /tmp/argocd https://github.com/argoproj/argo-cd/releases/download/$ARGOCD_VERSION/argocd-linux-amd64
sudo install -b /tmp/argocd /usr/local/bin
rm -f /tmp/argocd

# install kubectx and kubens
if [ ! -d /opt/kubectx ]; then
  sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
else
  cd /opt/kubectx
  sudo git pull
fi
cd $BASEDIR
sudo ln -fs /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -fs /opt/kubectx/kubens /usr/local/bin/kubens
mkdir -p ~/.oh-my-zsh/completions
chmod -R 755 ~/.oh-my-zsh/completions
ln -fs /opt/kubectx/completion/_kubectx.zsh ~/.oh-my-zsh/completions/_kubectx.zsh
ln -fs /opt/kubectx/completion/_kubens.zsh ~/.oh-my-zsh/completions/_kubens.zsh

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
