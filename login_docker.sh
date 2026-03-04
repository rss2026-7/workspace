#!/usr/bin/env bash
# SSH into the robot and enter the docker container.
# Usage: ./login_docker.sh

source "$(dirname "$0")/VARIABLES"
sshpass -p "$PASS" ssh -t -o StrictHostKeyChecking=no "$ROBOT" "echo $PASS | sudo -S true 2>/dev/null && bash -ic connect"
rc=$?
if [[ $rc -ne 0 ]]; then
  case $rc in
    5)  die "SSH authentication failed. Check the password in VARIABLES." ;;
    255) die "SSH connection to $ROBOT failed. Is the robot powered on and connected?" ;;
    *)  die "Docker container may not be running. Try running ./start.sh first (exit code $rc)." ;;
  esac
fi
