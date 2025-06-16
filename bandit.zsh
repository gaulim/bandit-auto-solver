#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

this_file=$(basename "$0")

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"

typeset user
typeset level
typeset cmd
typeset result
typeset -i result_code

echo "\n$this_file - Bandit Solution Script"
echo

# --- Level selection ---
read "level?Enter Bandit level: "

case $level in
    0)
        cmd="sed -n 's/^.*: //p' readme 2>/dev/null"
        ;;
    *)
        echo "\n[INFO] This level $level is still being solved. Updates will be posted soon."
        exit 1
        ;;
esac

user="bandit$level"

# --- Run Command ---
result=$(ssh -o StrictHostKeyChecking=no -p $PORT ${user}@${HOST} "$cmd")
result_code=$?

if [[ $result_code -ne 0 ]]; then
    echo "\n[ERROR] Command failed."
    exit 1
fi

echo "\n[RESULT] [Level $level → Level $((level + 1))] password: $result"

exit 0
