#!/usr/bin/env bash
# Download a directory from ~/racecar_ws/src/ on the robot to the current directory.
# Usage: ./download.sh <name>        — downloads ~/racecar_ws/src/<name> to .
#        ./download.sh <name> <dest> — downloads to custom local destination

set -e
source "$(dirname "$0")/VARIABLES"
require_cmd tar

NAME="${1:?Usage: ./download.sh <name> [local_dest]}"
NAME="${NAME%/}"
check_ssh
SRC="~/racecar_ws/src/${NAME}"
DEST="${2:-.}"
TARNAME="/tmp/${NAME}.tar.gz"
cleanup() { rm -f "$TARNAME"; }
trap cleanup EXIT

# On the robot: tar up the directory
if ! $SSH "tar czf /home/racecar/${NAME}.tar.gz --exclude='__pycache__' -C ~/racecar_ws/src ${NAME}"; then
  die "Remote archive failed. Check that '${SRC}' exists on the robot."
fi

# Download tarball from robot
if ! $SCP "$ROBOT:/home/racecar/${NAME}.tar.gz" "$TARNAME"; then
  die "SCP download failed. Check network connectivity."
fi

# Clean up remote tarball
$SSH "rm -f /home/racecar/${NAME}.tar.gz" || true

# Extract locally: remove old dir, then extract
rm -rf "${DEST}/${NAME}"
tar xzf "$TARNAME" -C "$DEST" \
  || die "Local extraction failed. Check that '${DEST}' exists and is writable."

echo "Downloaded ${NAME} to ${DEST}/${NAME}"
