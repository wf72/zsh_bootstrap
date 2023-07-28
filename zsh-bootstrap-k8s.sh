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
	sudo apt -y install zsh wget git exa curl build-essential
fi

if [ "$DISTRO" == "freebsd" ]; then
	sudo pkg install -y zsh wget git exa curl build-essential
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

# install vim-plug
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
vim +PlugInsall +qall

# install homebrew https://brew.sh/
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# install spacer https://github.com/samwho/spacer
brew install spacer

# install zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting
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

# k8s
# install helm
brew install helm

# install kubecolor https://github.com/hidetatz/kubecolor
brew install hidetatz/tap/kubecolor

# install k9s https://k9scli.io/
brew install derailed/k9s/k9s

# install krew https://krew.sigs.k8s.io/docs/user-guide/setup/install/
cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  ./"${KREW}" install krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
cd $BASEDIR

# ktop https://github.com/vladimirvivien/ktop
kubectl krew install ktop

# kubelogin aka oidc-login https://github.com/int128/kubelogin
kubectl krew install oidc-login

# ketall https://github.com/corneliusweig/ketall
kubectl krew install get-all

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
