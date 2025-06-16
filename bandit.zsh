#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

ssh -p 2220 bandit0@bandit.labs.overthewire.org "cat readme"

exit 0
