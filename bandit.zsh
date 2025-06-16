#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

this_file=$(basename "$0")

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"
readonly USER="bandit0"
readonly CMD="sed -n 's/^.*: //p' readme 2>/dev/null"

typeset result
typeset -i result_code

echo "\n$this_file - Bandit Solution Script"
echo

# --- Run Command ---
result=$(ssh -o StrictHostKeyChecking=no -p $PORT ${USER}@${HOST} "$CMD")
result_code=$?

if [[ $result_code -ne 0 ]]; then
    echo "\n[ERROR] Command failed."
    exit 1
fi

echo "\n[RESULT] [Level 0 → Level 1] password: $result"

exit 0
