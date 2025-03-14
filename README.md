# ZSH Boostrap scripts

Для использования необходим sudo, установите перед началом использования (хотя он обычно установлен во всех системах).
```
apt update
apt -y install sudo
```

Проверен на:
* Ubuntu LTS 20.04-22.04
* Debian 10-12
* Centos 8
* Oracle Linux 8-9
* Macos 14

Не работает:
* на Linux с процессорами Arm из-за ограничений brew
* под пользователем root из-за ограничений brew

# Скрипт устанавливает:

* zsh
* [oh-my-zsh](https://ohmyz.sh/)
* [zellij](https://zellij.dev/)
* git
* curl
* [brew](https://brew.sh/)
* [eza](https://github.com/eza-community/eza)
* [vim-plug](https://github.com/junegunn/vim-plug)
* [spacer](https://github.com/samwho/spacer)
* [hstr](https://github.com/dvorka/hstr)

В .zshrc основные настройки/дополнения:

* git - Плагин для git
* zsh-autosuggestions - Плагин автодоплнения из истории
* command-not-found - если комманда не найдена, показывает как установить
* еще несколько плагинов с алиасами и автодополнениями, например по sudo, pip, python
* [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
* изменена стандартная тема
* изменён prompt

В zellij увеличина история прокрутки



## vim
Для vim устанавливаются:
 - Плагин [vim-airline](https://github.com/vim-airline/vim-airline)
 - Тема [tender](https://github.com/jacoborus/tender.vim)

## k8s
Версия с постфиксом k8s настраивает оболочку для удобной работы с kubernetes. Дополнительно устанавливаются:
* kubectl v1.23.4
* argocd cli v2.6.11
* helm
* [k9s](https://k9scli.io/)
* [KUBE_PS1](https://github.com/jonmosco/kube-ps1) и изменяет промпт для отображения context и namespace
* [kubectx, kubens](https://github.com/ahmetb/kubectx)
* [kubecolor] https://github.com/hidetatz/kubecolor
* alias kubectl=k
* [krew](https://krew.sigs.k8s.io/)
* [ktop](https://github.com/vladimirvivien/ktop)
* [kubelogin](https://github.com/int128/kubelogin)
* [ketall](https://github.com/corneliusweig/ketall)


# install

```bash
git clone https://github.com/wf72/zsh_bootstrap.git
cd zsh_bootstrap/
bash ./zsh-bootstrap.sh
chsh -s /usr/bin/zsh
```

## Import history
Запускается автоматически и не требует одельного запуска.
```bash
python3 ./bash_to_zsh_history.py
```

# TODO
- [ ] install pygmentize
- [ ] disable k8s in prompt when install without it