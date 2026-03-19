#!/bin/bash
# webcam-capture-daemon.sh — Captures the default webcam at 1fps
# Handles:
#   - Sleep/wake (ffmpeg dies on sleep, restarts on wake)
#   - Midnight rotation

# Prevent duplicate instances
LOCKFILE="/tmp/webcam-capture-daemon-$(id -u).lock"
if pgrep -f "/usr/local/bin/webcam-capture-daemon.sh" | grep -v "$$" > /dev/null; then
  exit 0
fi
rmdir "$LOCKFILE" 2>/dev/null
if ! mkdir "$LOCKFILE" 2>/dev/null; then
  exit 0
fi
trap 'rmdir "$LOCKFILE" 2>/dev/null' EXIT

CAPTURE_DIR="$HOME/screen-recordings"
LOG_DIR="$CAPTURE_DIR/logs"
mkdir -p "$LOG_DIR"

# Configurable FPS for webcam
WEBCAM_FPS=1

echo "[$(date)] Webcam Daemon starting (PID $$) at $WEBCAM_FPS FPS"

# Find FaceTime HD Camera index
DEVICE_INDEX=$(ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | grep "FaceTime HD Camera" | head -n 1 | sed -E 's/.*\[([0-9]+)\].*/\1/')

if [ -z "$DEVICE_INDEX" ]; then
  echo "[$(date)] No webcam detected. Retrying in 60s..."
  sleep 60
  exit 1
fi

while true; do
  DATE=$(date +%Y-%m-%d)
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  OUTPUT_DIR="$CAPTURE_DIR/$DATE"
  mkdir -p "$OUTPUT_DIR"
  
  OUTFILE="$OUTPUT_DIR/webcam-${TIMESTAMP}.mp4"
  echo "[$(date)] Starting webcam capture -> $(basename "$OUTFILE")"

  # Calculate seconds until midnight
  NOW=$(date +%s)
  MIDNIGHT=$(date -j -f "%Y-%m-%d %H:%M:%S" "$(date -v+1d +%Y-%m-%d) 00:00:00" +%s 2>/dev/null || date -d "tomorrow 00:00" +%s)
  DURATION=$(( MIDNIGHT - NOW ))

  # Capture webcam. Using low resolution to save space since it's just for reference.
  ffmpeg -f avfoundation -framerate "$WEBCAM_FPS" -i "$DEVICE_INDEX" \
    -vf "fps=$WEBCAM_FPS,scale=640:-2" \
    -c:v libx264 -crf 32 -preset ultrafast \
    -movflags frag_keyframe+empty_moov \
    -t "$DURATION" \
    -y "$OUTFILE" \
    </dev/null >> "$LOG_DIR/webcam-${DATE}.log" 2>&1 &
  FFMPEG_PID=$!

  # Watchdog: wait for ffmpeg to exit or midnight
  while kill -0 "$FFMPEG_PID" 2>/dev/null; do
    sleep 5
    CURRENT_DATE=$(date +%Y-%m-%d)
    if [ "$CURRENT_DATE" != "$DATE" ]; then
      kill "$FFMPEG_PID" 2>/dev/null || true
      break
    fi
  done

  sleep 3
done
