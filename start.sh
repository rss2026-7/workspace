#!/usr/bin/env bash
# Start the car: creates a tmux session with run_rostorch.sh and teleop.
# Usage: ./start.sh

set -e
source "$(dirname "$0")/VARIABLES"

start_processes() {
    # Pre-cache sudo credentials so run_rostorch.sh doesn't prompt
    $SSH "tmux send-keys -t default:0.0 'echo $PASS | sudo -S true 2>/dev/null && cd && ./run_rostorch.sh' Enter"
    $SSH "tmux split-window -t default:0 -v"
    # 'connect' enters the docker container, then run teleop inside it
    $SSH "tmux send-keys -t default:0.1 'echo $PASS | sudo -S true 2>/dev/null && connect' Enter"
    sleep 3
    $SSH "tmux send-keys -t default:0.1 'teleop' Enter"
    echo "Started run_rostorch.sh and teleop in tmux session 'default'."
    echo "Attach with: ./login.sh, then: tmux attach -t default"
}

# Check if tmux session "default" exists on the robot
if $SSH "tmux has-session -t default 2>/dev/null"; then
    echo "tmux session 'default' already exists, checking processes..."

    # [r] / [t] trick prevents pgrep from matching the ssh/grep command itself
    ROSTORCH=$($SSH "pgrep -f '[r]un_rostorch' > /dev/null 2>&1 && echo yes || echo no")
    TELEOP=$($SSH "pgrep -f '[t]eleop' > /dev/null 2>&1 && echo yes || echo no")

    if [[ "$ROSTORCH" == "yes" && "$TELEOP" == "yes" ]]; then
        echo "Both run_rostorch and teleop are already running. Car is ready!"
        exit 0
    elif [[ "$ROSTORCH" == "no" && "$TELEOP" == "no" ]]; then
        echo "Neither process running. Recreating session..."
        $SSH "tmux kill-session -t default"
        $SSH "tmux new-session -d -s default"
        start_processes
    else
        echo "ERROR: Inconsistent state — only one process is running."
        [[ "$ROSTORCH" == "yes" ]] && echo "  run_rostorch is RUNNING, but teleop is NOT."
        [[ "$TELEOP" == "yes" ]] && echo "  teleop is RUNNING, but run_rostorch is NOT."
        echo "Fix manually before running start.sh again."
        exit 1
    fi
else
    echo "Creating tmux session 'default'..."
    $SSH "tmux new-session -d -s default"
    start_processes
fi
