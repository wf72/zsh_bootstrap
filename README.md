# ZSH Boostrap scripts

Скрипт устанавливает:

    zsh
    oh-my-zsh
    zsh-autosuggestions
    tmux
    git
    wget

В .zshrc основные настройки:

	При подключении к хосту по ssh запускается tmux
	git - Плагин для git
	zsh-autosuggestions - Плагин автодоплнения из истории
	command-not-found - если комманда не найдена, показывает как установить
	еще несколько плагинов с алиасами и автодополнениями, например по sudo, pip, python
	изменена стандартная тема
	изменён prompt

В .tmux.conf минимальные необходимые настройки, включен менеджер плагинов tpm и режим управления мышкой

Проверен на Ubuntu, Debian и FreeBSD (10.2)

# zsh install

```bash
cd ~
git clone https://github.com/wf72/zsh_bootstrap.git
cd zsh_bootstrap/
bash ./zsh-bootstrap.sh
```

## Import history
```bash
python3 ./bash_to_zsh_history.py
```

## vim install plugins
Для установки плагинов в Vim выполнить
:PlugInstall
