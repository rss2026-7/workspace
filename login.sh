#!/usr/bin/env bash
source "$(dirname "$0")/VARIABLES"
sshpass -p "$PASS" ssh "$ROBOT"
