#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

this_file=$(basename "$0")

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"
readonly USER="bandit0"
readonly CMD="sed -n 's/^.*: //p' readme 2>/dev/null"

echo "\n$this_file - Bandit Solution Script"
echo

ssh -o StrictHostKeyChecking=no -p $PORT ${USER}@${HOST} "$CMD"

exit 0
