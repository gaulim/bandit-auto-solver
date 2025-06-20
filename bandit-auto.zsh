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
            printf "\r[%c] Level $level ..." "${spin_chars:$i:1}"
            sleep $delay
        done
    done
    tput cnorm  # Restore cursor
    printf "\r"
}


# ------------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------------

readonly START_LEVEL=0
readonly END_LEVEL=34
readonly PASS_DIR="$HOME/.bandit_pass"

typeset cmd_pid

print "\n$this_file - Auto-run all Bandit Solution Script\n"

for ((level = START_LEVEL; level <= END_LEVEL; level++)); do
    # Background execution
    zsh "$work_dir/bandit.zsh" --no-interactive --quiet --level="$level" &
    cmd_pid=$!

    show_spinner $cmd_pid
    wait $cmd_pid
    RESULT_CODE=$?

    if [[ $RESULT_CODE -eq 0 ]]; then
        printf "[O] Level $level success.\n"
        printf "[ ] Level $((level + 1)) ..."
        sleep 1
    else
        printf "[X] Level $level failed.\n"
        break
    fi
done

print "\n[COMPLETE] All level processed up to Level $level. Passwords stored in $PASS_DIR\n"

exit 0
