#!/usr/bin/env bash

SCRIPT=$(readlink -f "$0")
BASEDIR=$(dirname "$SCRIPT")
ZSH_CUSTOM=$HOME/.oh-my-zsh/custom

# install zsh
sudo apt install zsh wget git ruby

cd $HOME

# install oh my zsh. source https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh

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
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

cd $BASEDIR

# replace home dir in our config
sed -i "s,HOME_DIR,$HOME," $BASEDIR/zshrc
cp $BASEDIR/zshrc ~/.zshrc

#import bash history to zsh
python ./bash_to_zsh_history.py
