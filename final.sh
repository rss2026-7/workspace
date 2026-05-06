#!/usr/bin/env bash
# Upload ../final_challenge2026 to ~/racecar_ws/src/ on the robot.
# Excludes __pycache__, .venv, media/, testing_images/, and bulky proof/ artifacts.
# Usage: ./final.sh

set -e
source "$(dirname "$0")/VARIABLES"
require_cmd tar

log() { printf '[final.sh] %s\n' "$*"; }

SRC="$(dirname "$0")/../final_challenge2026"
NAME="final_challenge2026"
TARNAME="/tmp/${NAME}.tar.gz"
DEST="~/racecar_ws/src"

log "Source:      $SRC"
log "Archive:     $TARNAME"
log "Robot:       $ROBOT"
log "Destination: $DEST/$NAME"

[[ ! -e "$SRC" ]] && die "Source path '$SRC' does not exist."

log "Checking SSH connection to $ROBOT..."
check_ssh
log "SSH connection OK."

cleanup() {
  if [[ -f "$TARNAME" ]]; then
    log "Cleaning up local archive $TARNAME"
    rm -f "$TARNAME"
  fi
}
trap cleanup EXIT

log "Creating tar archive (excluding __pycache__, .venv, media, testing_images, bulky proof/)..."
SRC_SIZE="$(du -sh "$SRC" 2>/dev/null | awk '{print $1}')"
log "  source size on disk: ${SRC_SIZE:-unknown}"
tar czf "$TARNAME" --no-xattrs \
  --exclude='__pycache__' \
  --exclude='.venv' \
  --exclude='media' \
  --exclude='testing_images' \
  --exclude='proof/rosbag2_*' \
  --exclude='proof/output.mp4' \
  --exclude='proof/sample_t*.png' \
  --exclude='*.pt' \
  --exclude='*.MOV' \
  --exclude='*.mp4' \
  --exclude='lane_tune.tar.gz' \
  -C "$(dirname "$SRC")" "$NAME" \
  || die "Failed to create archive from '$SRC'. Check that you have read permissions."
TAR_SIZE="$(du -sh "$TARNAME" 2>/dev/null | awk '{print $1}')"
log "Archive created: $TARNAME (${TAR_SIZE:-unknown})"

log "Uploading archive via scp to $ROBOT:/home/racecar/${NAME}.tar.gz..."
if ! $SCP "$TARNAME" "$ROBOT:/home/racecar/${NAME}.tar.gz"; then
  die "SCP upload failed. Check network connectivity and that the robot has enough disk space."
fi
log "Upload complete."

log "Extracting on robot (sudo password is auto-supplied; you should NOT be prompted)..."
REMOTE_CMD=$(cat <<EOF
set -e
sudo -k
printf '%s\n' "$PASS" | sudo -S -p '' rm -rf ${DEST}/${NAME}
tar xzf /home/racecar/${NAME}.tar.gz -C ${DEST}
rm -f /home/racecar/${NAME}.tar.gz
EOF
)
if ! $SSH "$REMOTE_CMD"; then
  die "Remote extraction failed. Check that '${DEST}' exists and is writable on the robot."
fi
log "Remote extraction complete."

log "Done. Uploaded ${NAME} to ${DEST}/${NAME}"
