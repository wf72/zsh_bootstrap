Для установки использовать: zsh-bootstrap.sh

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

Проверен на Ubuntu и FreeBSD (10.2)
