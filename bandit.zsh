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
    local tag

    if [ -z "$message" ]; then
        return
    fi

    case "$variant" in
        info)
            tag="INFO"
            [[ "false" == $quiet ]] && printf "\n\033[34m[$tag]\033[0m $message\n"
            ;;
        result)
            tag="RESULT"
            [[ "false" == $quiet ]] && printf "\n\033[32m[$tag]\033[0m $message\n"
            ;;
        warn)
            tag="WARN"
            [[ "false" == $quiet ]] && printf "\n\033[33m[$tag]\033[0m $message\n"
            ;;
        error)
            tag="ERROR"
            [[ "false" == $quiet ]] && printf "\n\033[31m[$tag]\033[0m $message\n"
            ;;
        *)
            print "\n❌ Invalid log variant. [message: $message]"
            exit 1
            ;;
    esac

    # Add to log file
    local log=$(print "$(date +%T) [$tag] $message\n" 2>&1)
    print -r -- "$log" >> "$LOG_DIR/$log_file"
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

# Usage: install_if_command_not_exist <command_name> [<package_name>]
function install_if_command_not_exist() {
    local command_name="$1"
    local package_name="${2:-$1}"

    if [[ -z "$command_name" ]]; then
        logger "error" "❌ Command name is required."
        return 1
    fi

    if ! command -v "$command_name" &> /dev/null; then
        logger "warn" "🔍 Command '$command_name' not found. Trying to install '$package_name'..."

        if command -v brew &> /dev/null; then
            logger "info" "📦 Installing '$package_name' via Homebrew..."
            if [[ "false" == $dry_run ]]; then
                if [[ "true" == $quiet ]]; then
                    brew install -q "$package_name" >/dev/null 2>&1
                else
                    print ""
                    brew install -q "$package_name"
                fi
            fi
        elif command -v yum &> /dev/null; then
            logger "info" "📦 Installing '$package_name' via yum..."
            if [[ "false" == $dry_run ]]; then
                if [[ "true" == $quiet ]]; then
                    sudo yum -y -q install "$package_name" >/dev/null 2>&1
                else
                    print ""
                    sudo yum -y -q install "$package_name"
                fi
            fi
        elif command -v apt &> /dev/null; then
            logger "info" "📦 Installing '$package_name' via apt..."
            if [[ "false" == $dry_run ]]; then
                if [[ "true" == $quiet ]]; then
                    sudo apt -y -q install "$package_name" >/dev/null 2>&1
                else
                    print ""
                    sudo apt -y -q install "$package_name"
                fi
            fi
        else
            logger "error" "❌ No supported package manager found to install '$package_name'."
            return 1
        fi
    fi

    return 0
}

function install_require_packages() {

    # --- Install jq ---
    install_if_command_not_exist jq

    # --- Install sshpass if not interactive ---
    if [[ "false" == $interactive ]]; then
        install_if_command_not_exist sshpass
    fi

    return 0
}


# ------------------------------------------------------------------------------
# Entry point
# ------------------------------------------------------------------------------

readonly PORT=2220
readonly HOST="bandit.labs.overthewire.org"
readonly START_LEVEL=0
readonly END_LEVEL=34

readonly ENTRY_JSON="$work_dir/bandit-levels.json"
readonly PASS_DIR="$HOME/.bandit_pass"
readonly LOG_DIR="/tmp/bandit-auto-solver/logs"

typeset log_file="$(date +%F).log"  # YYYY-MM-DD.log

typeset level_arg=""
typeset interactive="true"
typeset quiet="false"
typeset test="false"
typeset dry_run="false"

typeset level_input
typeset -i level

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
        --test)
            level_arg=0
            interactive="false"
            quiet="true"
            test="true"
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

# --- Install require packages ---
install_require_packages

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

typeset user="bandit$level"
typeset current_pwd_file="bandit$(printf '%02d' $level)"
typeset next_pwd_file="bandit$(printf '%02d' $((level + 1)))"
typeset entry
typeset password
typeset command
typeset result
typeset -i result_code

# --- Load entry ---
entry=$(jq -c ".[] | select(.level == $level)" "$ENTRY_JSON" 2>/dev/null)
if [[ -z "$entry" ]]; then
    logger "warn" "This level $level is still being solved. Updates will be posted soon."
    exit 1
fi

# --- Load password if available ---
if [[ -f "$PASS_DIR/$current_pwd_file" ]]; then
    password=$(< "$PASS_DIR/$current_pwd_file")
else
    logger "error" "Password for level $level not found in $PASS_DIR"
    exit 1
fi

command=$(echo "$entry" | jq -r '.runner')
logger "info" "CMD: $command"

# --- Run Command ---
result=$(remote_execute_command "$user" "$password" "$command")
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

# Test only
if [[ "true" == $test ]]; then
    password="$result"
    remote_execute_command "bandit$((level + 1))" "$password" "echo"
    result_code=$?
    if [[ $result_code -eq 0 ]]; then
        printf "\033[32m[RESULT]\033[0m Test: OK!\n"
    else
        printf "\033[32m[RESULT]\033[0m Test: Not OK!\n"
    fi
fi

exit 0
