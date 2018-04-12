#!/usr/bin/env python3
# author wf
# = This script transfers bash history to zsh history
# = Change bash and zsh history files, if you don't use defaults
#
# = Usage: python bash_to_zsh_history.py
# thanks to Ankit Goyal for ruby script
# -*- coding: utf-8 -*-

import os
import sys
import calendar
import time


def main():
    bash_history_file_path = "{}/.bash_history".format(os.environ.get("HOME"))
    zsh_history_file_path = "{}/.zsh_history".format(os.environ.get("HOME"))
    bash_hist_file = open(bash_history_file_path, 'r')
    zsh_hist_file = open(zsh_history_file_path, 'a')
    epoch_seconds = calendar.timegm(time.gmtime())
    for line in bash_hist_file:
        zsh_hist_file.write(": {time}:0;{command}\n".format(time=epoch_seconds,command=line))
    zsh_hist_file.close()
    bash_hist_file.close()


if __name__ == '__main__':
    sys.exit(main())