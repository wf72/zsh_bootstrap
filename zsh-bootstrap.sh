#!/usr/bin/env bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom
zshrc_template="zshrc"
VALID_ARGS=$(getopt -o k,m --long k8s,manual -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -k | --k8s)
        echo "Processing k8s option"
		k8s_install="non zero string ;)"
		zshrc_template="zshrc-k8s"
        shift
        ;;
    -m | --manual)
        echo "Processing manual option. Manually install packages: zsh wget git curl sqlite"
		manual_packet_install="non zero string ;)"
        shift
        ;;
    --) shift; 
        break 
        ;;
  esac
done

# check sudo
if test -z "$(type sudo)"; then
	echo "sudo command not found. Please install it before begin."
	exit 1
fi

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

case $DISTRO in
	"Ubuntu")
		sudo apt update
		sudo apt -y install zsh wget git curl vim passwd
		if [ $? -gt 0 ]; then
			exit 1
		fi
		sudo apt -y install exa
		if [ $? -eq 0 ]; then
			exa_installed="one more non zero string"
		fi
		;;
	*"debian"*)
		sudo apt update
		sudo apt -y install zsh wget git curl vim exa passwd
		if [ $? -gt 0 ]; then
			exit 1
		fi
		exa_installed="one more non zero string"
		;;
	*"redhat"*)
		sudo yum install -y zsh wget git curl sqlite vim util-linux-user
		if [ $? -gt 0 ]; then
			exit 1
		fi
		;;
	*)
		if ! test -z manual_packet_install; then
			echo -e "I dont know your distr.\nPlease, manualy install zsh wget git exa curl sqlite.\nAfter install run script with option --manual"
			exit 1
		fi
		;;
esac

unset DISTRO

cd $HOME

# install or update oh-my-zsh https://ohmyz.sh/
if test -d $HOME/.oh-my-zsh; then
	$HOME/.oh-my-zsh/tools/upgrade.sh
else
	### install oh_my_zsh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/ohmyzshinstall.sh
	sh /tmp/ohmyzshinstall.sh --unattended
	if [ $? -gt 0 ]; then
		exit 1
	fi
	rm /tmp/ohmyzshinstall.sh
fi
# install or update autosuggestions
if [ ! -d $ZSH_CUSTOM/plugins/zsh-autosuggestions ]; then
	git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
	if [ $? -gt 0 ]; then
		exit 1
	fi
else
	cd $ZSH_CUSTOM/plugins/zsh-autosuggestions
	git pull
	if [ $? -gt 0 ]; then
		exit 1
	fi
fi

cd $BASEDIR

# replace home dir in our config
if [ -f $HOME/.zshrc ] || [ -h $HOME/.zshrc ]; then
	mv $HOME/.zshrc $HOME/.zshrc.bak;
fi

cat $BASEDIR/$zshrc_template | sed "s,HOME_DIR,$HOME," > $HOME/.zshrc
if test ! -z "$exa_installed"; then
	tee -a $HOME/.zshrc << END
# exa aliases
alias ls='exa'
alias lst='exa -T'
alias l='exa -lFh' 
alias la='exa -laFh'
alias ll='exa -l'

END
fi
# vimrc install
if [ -f $HOME/.vimrc ] || [ -h $HOME/.vimrc ]; then
	mv $HOME/.vimrc $HOME/.vimrc.bak;
fi

cp $BASEDIR/.vimrc $HOME/.vimrc

# install vim-plug
if [ ! -f $HOME/.vim/autoload/plug.vim ]; then
  curl -fLo $HOME/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi
sed -i 's/colorscheme tender/" colorscheme tender/g' $HOME/.vimrc
vim +PlugInstall +qall
sed -i 's/" colorscheme tender/colorscheme tender/g' $HOME/.vimrc
if [ $? -gt 0 ]; then
	echo "Something wrong in vim plugin install."
fi

# install homebrew https://brew.sh/
/bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
if [ $? -gt 0 ]; then
	exit 1
fi
# install spacer
brew tap samwho/spacer
brew install spacer

# install or update zsh-syntax-highlighting
if test ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting; then
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
else
	cd ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git pull
	cd -
fi

# isntall zellij (tmux analog, but more better)
curl -sSL https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz -o /tmp/zellij.tar.gz
tar -xzf /tmp/zellij.tar.gz -C /tmp
sudo install -b /tmp/zellij /usr/local/bin
rm -f /tmp/zellij

if ! test -d $HOME/.config/zellij; then
	mkdir -p $HOME/.config/zellij
fi

if [ -f $HOME/.config/zellij/config.kdl ] || [ -h $HOME/.config/zellij/config.kdl ]; then
	mv $HOME/.config/zellij/config.kdl $HOME/.config/zellij/config.kdl.bak;
fi
cp $BASEDIR/zellij.config.kdl $HOME/.config/zellij/config.kdl


# k8s
if test -z k8s; then
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
	mkdir -p $HOME/.oh-my-zsh/completions
	chmod -R 755 $HOME/.oh-my-zsh/completions
	ln -fs /opt/kubectx/completion/_kubectx.zsh $HOME/.oh-my-zsh/completions/_kubectx.zsh
	ln -fs /opt/kubectx/completion/_kubens.zsh $HOME/.oh-my-zsh/completions/_kubens.zsh
fi
#import bash history to zsh
if test ! -f $HOME/.zsh_history; then
	if test -z "$(type python3)"; then
		python3 ./bash_to_zsh_history.py
	elif test -z "$(type ruby)"; then
		ruby ./bash_to_zsh_history.rb
	fi
fi
echo -e "To change your default shell, run this command:\nchsh -s $(type -p zsh)"
unset SCRIPT
unset BASEDIR
unset ZSH_CUSTOM
