#!/usr/bin/env bash
# Upload a file or directory to ~/racecar_ws/src/ on the robot.
# Usage: ./upload.sh <path>        — uploads to ~/racecar_ws/src/
#        ./upload.sh <path> <dest> — uploads to custom destination

set -e
source "$(dirname "$0")/VARIABLES"

SRC="${1:?Usage: ./upload.sh <file_or_dir> [remote_dest]}"
SRC="${SRC%/}"
DEST="${2:-~/racecar_ws/src}"
NAME="$(basename "$SRC")"
TARNAME="/tmp/${NAME}.tar.gz"

# Tar up locally from parent dir so archive contains the directory name
tar czf "$TARNAME" --exclude='__pycache__' --exclude='.git' -C "$(dirname "$SRC")" "$NAME"

# Upload tarball to robot home dir
$SCP "$TARNAME" "$ROBOT:/home/racecar/${NAME}.tar.gz"

# Remove local tarball
rm "$TARNAME"

# On the robot: remove old dir, extract into dest, clean up tarball
$SSH "rm -rf ${DEST}/${NAME} && tar xzf /home/racecar/${NAME}.tar.gz -C ${DEST} && rm /home/racecar/${NAME}.tar.gz"

echo "Uploaded ${NAME} to ${DEST}/${NAME}"
