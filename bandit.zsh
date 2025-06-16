#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

this_file=$(basename "$0")
work_dir=$(dirname "$0")

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"
readonly START_LEVEL=0
readonly END_LEVEL=34

typeset pass_dir="$work_dir/.bandit_pass"
typeset log_dir="$work_dir/logs"

typeset level_input
typeset -i level
typeset cmd

printf "\n$this_file - Bandit Solution Script\n"

# --- Make directories ---
mkdir -p "$pass_dir" "$log_dir"

# --- Save level 0 password ---
if [[ ! -f "$pass_dir/bandit00" ]]; then
    echo "bandit0" > "$pass_dir/bandit00"
fi

# --- Level selection ---
echo
while true; do
    read "level_input?Enter Bandit level (${START_LEVEL}~$((END_LEVEL - 1))): "
    if [[ $level_input =~ '^[0-9]+$' && $level_input -ge $START_LEVEL && $level_input -lt $END_LEVEL ]]; then
        level=$level_input
        break
    fi
    printf "Invalid input.\n\n"
done

case $level in
    0)
        cmd="sed -n 's/^.*: //p' readme 2>/dev/null"
        ;;
    *)
        printf "\n[INFO] This level $level is still being solved. Updates will be posted soon.\n"
        exit 1
        ;;
esac

typeset user="bandit$level"
typeset pwd_file="bandit$(printf '%02d' $((level + 1)))"
typeset log_file="bandit$(printf '%02d' $level).log"
typeset result
typeset -i result_code

# --- Save command to log ---
echo "$cmd" > "$log_dir/$log_file"

# --- Run Command ---
result=$(ssh -o StrictHostKeyChecking=no -p $PORT ${user}@${HOST} "$cmd")
result_code=$?

if [[ $result_code -ne 0 ]]; then
    printf "\n[ERROR] Command failed.\n"
    exit 1
fi

# --- Save password ---
echo "$result" > "$pass_dir/$pwd_file"

# --- Output password ---
printf "\n[RESULT] [Level $level → Level $((level + 1))] password: $result\n"

exit 0
