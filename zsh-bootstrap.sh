#!/usr/bin/env bash

BASEDIR=$(dirname "$0")

# install zsh
sudo apt install zsh wget git

cd $HOME

# install oh my zsh
sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"

#install autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

#replace home dir in our config
sed -i 's/\{\{HOME_DIR\}\}/$HOME/' $BASEDIR/.zshrc
cp $BASEDIR/zshrc ~/.zshrc

#import bash history to zsh
ruby ./import_history.rb
