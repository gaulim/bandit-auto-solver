#!/usr/bin/env zsh

# bandit.zsh - Bandit level solver (Level 0 ~ 33)

unset LANG
unset LC_ALL

this_file=$(basename "$0")
work_dir=$(dirname "$0")


# ------------------------------------------------------------------------------
# Function declarations / implementations
# ------------------------------------------------------------------------------

# Usage: logger "info" "message"
function logger() {
    local variant="${1:-info}"
    local message="${2:-}"
    local log

    if [ -z "$message" ]; then
        return
    fi

    case "$variant" in
        info)
            printf "\n\033[34m[L%02d-INFO]\033[0m %s\n" "$level" "$message"
            log=$(printf "%s [INFO] %s\n" "$(date +%T)" "$message")
            ;;
        result)
            printf "\n\033[32m[L%02d-RESULT]\033[0m %s\n" "$level" "$message"
            log=$(printf "%s [RESULT] %s\n" "$(date +%T)" "$message")
            ;;
        warning)
            printf "\n\033[33m[L%02d-WARN]\033[0m %s\n" "$level" "$message"
            log=$(printf "%s [WARN] %s\n" "$(date +%T)" "$message")
            ;;
        error)
            printf "\n\033[31m[L%02d-ERROR]\033[0m %s\n" "$level" "$message"
            log=$(printf "%s [ERROR] %s\n" "$(date +%T)" "$message")
            ;;
    esac

    # Add to log file
    echo "$log" >> "$log_dir/$log_file"
}

function remote_execute_command() {
    local user="$1"
    local cmd="$2"
    local ssh_cmd="ssh -o StrictHostKeyChecking=no -p $PORT ${user}@${HOST} \"$cmd\""

    local result_code

    if [[ "true" == $dry_run ]]; then
        result="$ssh_cmd"
        result_code=0
    else
        result=$(eval "$ssh_cmd")
        result_code=$?
    fi

    echo $result
    return $((result_code & 0xFF))
}


# ------------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------------

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"
readonly START_LEVEL=0
readonly END_LEVEL=34

typeset pass_dir="$work_dir/.bandit_pass"
typeset log_dir="$work_dir/logs"

typeset level_arg=""
typeset dry_run="false"

typeset level_input
typeset -i level
typeset cmd

# --- Command line argument parsing ---
for arg in "$@"; do
    case $arg in
        --level=*)
            level_arg="${arg#*=}"
            ;;
        --dry-run)
            dry_run="true"
            ;;
    esac
done

printf "\n$this_file - Bandit Solution Script\n"

# --- Make directories ---
mkdir -p "$pass_dir" "$log_dir"

# --- Save level 0 password ---
if [[ ! -f "$pass_dir/bandit00" ]]; then
    echo "bandit0" > "$pass_dir/bandit00"
fi

# --- Level selection ---
if [[ -n $level_arg ]]; then
    if [[ $level_arg =~ '^[0-9]+$' && $level_arg -ge $START_LEVEL && $level_arg -lt $END_LEVEL ]]; then
        level=$level_arg
    else
        printf "\n[ERROR] Invalid level argument value.\n"
        exit 1
    fi
else
    echo
    while true; do
        read "level_input?Enter Bandit level (${START_LEVEL}~$((END_LEVEL - 1))): "
        if [[ $level_input =~ '^[0-9]+$' && $level_input -ge $START_LEVEL && $level_input -lt $END_LEVEL ]]; then
            level=$level_input
            break
        fi
        printf "Invalid input.\n\n"
    done
fi

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

if [[ $# -eq 0 ]]; then
    logger "info" "OPTIONS: (none)"
else
    logger "info" "OPTIONS: $*"
fi
logger "info" "LEVEL: $level"
logger "info" "USER: $user"
logger "info" "CMD: $cmd"

# --- Run Command ---
result=$(remote_execute_command "$user" "$cmd")
result_code=$?

if [[ $result_code -ne 0 ]]; then
    logger "error" "Command failed."
    exit 1
fi

if [[ "true" == $dry_run ]]; then
    # --- Output SSH Command ---
    logger "result" "[DRY-RUN] SSH Command: $result"
else
    # --- Save password and Output password ---
    echo "$result" > "$pass_dir/$pwd_file"
    logger "result" "[Level $level → Level $((level + 1))] password: $result"
fi

exit 0
