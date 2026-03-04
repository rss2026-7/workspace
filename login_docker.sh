#!/usr/bin/env bash
# SSH into the robot and enter the docker container.
# Usage: ./login_docker.sh

source "$(dirname "$0")/VARIABLES"
sshpass -p "$PASS" ssh -t "$ROBOT" "echo $PASS | sudo -S true 2>/dev/null && bash -ic connect"
