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
            [[ "false" == $quiet ]] && printf "\n\033[34m[INFO]\033[0m %s\n" "$message"
            log=$(printf "%s [INFO] %s\n" "$(date +%T)" "$message")
            ;;
        result)
            [[ "false" == $quiet ]] && printf "\n\033[32m[RESULT]\033[0m %s\n" "$message"
            log=$(printf "%s [RESULT] %s\n" "$(date +%T)" "$message")
            ;;
        warn)
            [[ "false" == $quiet ]] && printf "\n\033[33m[WARN]\033[0m %s\n" "$message"
            log=$(printf "%s [WARN] %s\n" "$(date +%T)" "$message")
            ;;
        error)
            [[ "false" == $quiet ]] && printf "\n\033[31m[ERROR]\033[0m %s\n" "$message"
            log=$(printf "%s [ERROR] %s\n" "$(date +%T)" "$message")
            ;;
    esac

    # Add to log file
    echo "$log" >> "$LOG_DIR/$log_file"
}

function remote_execute_command() {
    local user="$1"
    local pwd="$2"
    local cmd="$3"
    local ssh_cmd

    local result_code

    if [[ "true" == $interactive ]]; then
        ssh_cmd="ssh -o StrictHostKeyChecking=no -p $PORT ${user}@${HOST} \"$cmd\""
    else
        ssh_cmd="sshpass -p \"$pwd\" ssh -T -o LogLevel=ERROR -o StrictHostKeyChecking=no -p $PORT ${user}@${HOST} \"$cmd\""
    fi

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

readonly PASS_DIR="$HOME/.bandit_pass"
readonly LOG_DIR="/tmp/bandit-auto-solver/logs"

typeset log_file="$(date +%F).log"  # YYYY-MM-DD.log

typeset level_arg=""
typeset interactive="true"
typeset dry_run="false"
typeset quiet="false"

typeset level_input
typeset -i level
typeset cmd

# --- Make directories ---
mkdir -p "$PASS_DIR" "$LOG_DIR"

# --- Command line argument parsing ---
for arg in "$@"; do
    case $arg in
        --level=*)
            level_arg="${arg#*=}"
            ;;
        --no-interactive)
            interactive="false"
            ;;
        --quiet)
            quiet="true"
            ;;
        --dry-run)
            dry_run="true"
            ;;
    esac
done

[[ "false" == $quiet ]] && printf "\n$this_file - Bandit Solution Script\n"

logger "info" "FILE: $this_file"

if [[ $# -eq 0 ]]; then
    logger "info" "OPTIONS: (none)"
else
    logger "info" "OPTIONS: $*"
fi

# --- Save level 0 password ---
if [[ ! -f "$PASS_DIR/bandit00" ]]; then
    echo "bandit0" > "$PASS_DIR/bandit00"
fi

# --- Level selection ---
if [[ -n $level_arg ]]; then
    if [[ $level_arg =~ '^[0-9]+$' && $level_arg -ge $START_LEVEL && $level_arg -lt $END_LEVEL ]]; then
        level=$level_arg
    else
        logger "error" "This level $level_arg is invalid."
        exit 1
    fi
elif [[ "true" == $interactive ]]; then
    echo
    while true; do
        read "level_input?Enter Bandit level (${START_LEVEL}~$((END_LEVEL - 1))): "
        if [[ $level_input =~ '^[0-9]+$' && $level_input -ge $START_LEVEL && $level_input -lt $END_LEVEL ]]; then
            level=$level_input
            break
        fi
        printf "Invalid input.\n\n"
    done
else
    logger "error" "No level provided and interactive mode disabled."
    exit 1
fi

logger "info" "LEVEL: $level"

case $level in
    0)
        cmd="sed -n 's/^.*: //p' readme 2>/dev/null"
        ;;
    *)
        logger "warn" "This level $level is still being solved. Updates will be posted soon."
        exit 1
        ;;
esac

logger "info" "CMD: $cmd"

typeset user="bandit$level"
typeset current_pwd_file="bandit$(printf '%02d' $level)"
typeset next_pwd_file="bandit$(printf '%02d' $((level + 1)))"
typeset password
typeset result
typeset -i result_code

# --- Load password if available ---
if [[ -f "$PASS_DIR/$current_pwd_file" ]]; then
    password=$(< "$PASS_DIR/$current_pwd_file")
else
    logger "error" "Password for bandit$level not found in $PASS_DIR"
    exit 1
fi

# --- Run Command ---
result=$(remote_execute_command "$user" "$password" "$cmd")
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
    echo "$result" > "$PASS_DIR/$next_pwd_file"
    logger "result" "[Level $level → Level $((level + 1))] password: $result"
fi

exit 0
