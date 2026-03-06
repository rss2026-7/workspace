#!/usr/bin/env bash
source "$(dirname "$0")/VARIABLES"
sshpass -p "$PASS" ssh -o StrictHostKeyChecking=no -L 6081:localhost:6081 "$ROBOT"
rc=$?
if [[ $rc -ne 0 ]]; then
  case $rc in
    5)  die "SSH authentication failed. Check the password in VARIABLES." ;;
    255) die "SSH connection to $ROBOT failed. Is the robot powered on and connected?" ;;
    *)  die "SSH session exited with code $rc." ;;
  esac
fi
