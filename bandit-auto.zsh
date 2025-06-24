#!/usr/bin/env zsh

# Auto-run all Bandit levels with stored passwords

unset LANG
unset LC_ALL

this_file=$(basename "$0")
work_dir=$(dirname "$0")


# ------------------------------------------------------------------------------
# Function declarations / implementations
# ------------------------------------------------------------------------------

function show_spinner() {
    local pid=$1
    local delay=0.1
    local spin_chars='|/-\'

    tput civis  # Hide cursor
    while kill -0 $pid 2>/dev/null; do
        for ((i = 0; i < ${#spin_chars}; i++)); do
            printf "\r[%c] [Level $level → Level $((level + 1))] 🔍 ..." "${spin_chars:$i:1}"
            sleep $delay
        done
    done
    tput cnorm  # Restore cursor
    printf "\r"
}

function load_password() {
    local level="${1:-0}"

    if [[ 1 > $level ]]; then
        loaded_password="bandit0"  # Level 0 password
        return 0
    fi

    local password_file="bandit$(printf '%02d' $level)"
    if [[ -f "$PASS_DIR/$password_file" ]]; then
        loaded_password=$(< "$PASS_DIR/$password_file")
        return $?
    else
        load_password=""
        return 1
    fi
}


# ------------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------------

readonly START_LEVEL=0
readonly END_LEVEL=34
readonly PASS_DIR="$HOME/.bandit_pass"

typeset loaded_password
typeset cmd_pid

print "\n$this_file - Auto-run all Bandit Solution Script\n"

for ((level = START_LEVEL; level <= END_LEVEL; level++)); do
    # Load password for next level
    load_password $((level + 1))
    if [[ $? -eq 0 && $loaded_password =~ '^[A-Za-z0-9]{32}$' ]]; then
        printf "\r[O] [Level $level → Level $((level + 1))] ✅ password: $loaded_password\n"
        printf "[ ] [Level $((level + 1)) → Level $((level + 2))] 🔍 ..."
        continue;
    fi

    # Background execution
    zsh "$work_dir/bandit.zsh" --no-interactive --quiet --level="$level" &
    cmd_pid=$!

    show_spinner $cmd_pid
    wait $cmd_pid
    RESULT_CODE=$?

    if [[ $RESULT_CODE -eq 0 ]]; then
        load_password $((level + 1))
        printf "\r[O] [Level $level → Level $((level + 1))] ✅ password: $loaded_password\n"
        printf "[ ] [Level $((level + 1)) → Level $((level + 2))] 🔍 ..."
        sleep 1
    else
        printf "[X] [Level $level → Level $((level + 1))] ❌ failed.\n"
        break
    fi
done

print "\n[COMPLETE] All level processed up to Level $level. Passwords stored in $PASS_DIR\n"

exit 0
