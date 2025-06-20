#!/usr/bin/env zsh

# Auto-run all Bandit levels with stored passwords

unset LANG
unset LC_ALL

this_file=$(basename "$0")
work_dir=$(dirname "$0")

readonly START_LEVEL=0
readonly END_LEVEL=34
readonly PASS_DIR="$HOME/.bandit_pass"

echo "\n$this_file - Auto-run all Bandit Solution Script"

for ((level = START_LEVEL; level <= END_LEVEL; level++)); do
    echo "\n[RUNNING] Level $level"

    zsh "$work_dir/bandit.zsh" --no-interactive --quiet --level="$level"
    RESULT_CODE=$?

    if [[ $RESULT_CODE -eq 0 ]]; then
        echo "[DONE] Level $level success."
        sleep 1
    else
        echo "[FAIL] Level $level execution failed. Halting."
        break
    fi
done

echo "\n[COMPLETE] All level processed up to Level $level. Passwords stored in $PASS_DIR\n"

exit 0
