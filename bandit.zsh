#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

this_file=$(basename "$0")

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"
readonly USER="bandit0"
readonly CMD="cat readme"

echo "\n$this_file - Bandit Solution Script"
echo

ssh -p $PORT ${USER}@${HOST} "$CMD"

exit 0
