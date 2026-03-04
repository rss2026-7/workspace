#!/usr/bin/env bash
# Upload a file or directory to ~/racecar_ws/src/ on the robot.
# Usage: ./upload.sh <path>        — uploads to ~/racecar_ws/src/
#        ./upload.sh <path> <dest> — uploads to custom destination

set -e
source "$(dirname "$0")/VARIABLES"
require_cmd tar

SRC="${1:?Usage: ./upload.sh <file_or_dir> [remote_dest]}"
SRC="${SRC%/}"
[[ ! -e "$SRC" ]] && die "Source path '$SRC' does not exist."
check_ssh
DEST="${2:-~/racecar_ws/src}"
NAME="$(basename "$SRC")"
TARNAME="/tmp/${NAME}.tar.gz"
cleanup() { rm -f "$TARNAME"; }
trap cleanup EXIT

# Tar up locally from parent dir so archive contains the directory name
tar czf "$TARNAME" --exclude='__pycache__' --exclude='.git' -C "$(dirname "$SRC")" "$NAME" \
  || die "Failed to create archive from '$SRC'. Check that you have read permissions."

# Upload tarball to robot home dir
if ! $SCP "$TARNAME" "$ROBOT:/home/racecar/${NAME}.tar.gz"; then
  die "SCP upload failed. Check network connectivity and that the robot has enough disk space."
fi

# On the robot: remove old dir, extract into dest, clean up tarball
if ! $SSH "rm -rf ${DEST}/${NAME} && tar xzf /home/racecar/${NAME}.tar.gz -C ${DEST} && rm /home/racecar/${NAME}.tar.gz"; then
  die "Remote extraction failed. Check that '${DEST}' exists and is writable on the robot."
fi

echo "Uploaded ${NAME} to ${DEST}/${NAME}"
