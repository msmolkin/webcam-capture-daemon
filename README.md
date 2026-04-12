# Webcam Capture Daemon for macOS

A lightweight, automated background webcam capture system for macOS that records your FaceTime HD Camera (or any default camera) at 1 FPS.

Designed to be a "set and forget" companion to the [screen capture daemon](https://github.com/msmolkin/screen-capture-daemon), it allows you to have a low-framerate video log of your webcam for reference.

## Features

- **Automated Capture:** Records at 1 FPS by default (configurable via menubar).
- **Background Operation:** Runs as a macOS LaunchAgent with `KeepAlive` — auto-restarts on `pkill`.
- **Robustness:** Handles system sleep/wake, lid close/open, and automatic daily rotation.
- **Low Impact:** Captures at 640px wide with high compression to minimize CPU and disk usage.
- **Pause/Resume:** Supports pause and resume via `~/.capture_config` (controlled by the [CaptureMenuApp](https://github.com/msmolkin/screen-capture-daemon#capturemenuapp-menubar-controller) menubar controller).
- **Adjustable FPS:** Frame rate can be changed live from the menubar without restarting.

## Installation

### 1. Requirements

- **macOS**
- **ffmpeg** (Install via Homebrew: `brew install ffmpeg`)

### 2. Setup Scripts

Copy the scripts to a location in your `PATH` (e.g., `/usr/local/bin/`):

```bash
cp webcam-capture-daemon.sh /usr/local/bin/
cp daily-stitch.sh /usr/local/bin/
chmod +x /usr/local/bin/webcam-capture-daemon.sh /usr/local/bin/daily-stitch.sh
```

### 3. Install the LaunchAgent

Copy the `.plist` file to your user's LaunchAgents directory:

```bash
mkdir -p ~/Library/LaunchAgents
cp com.michaelcli.webcam-capture.plist ~/Library/LaunchAgents/
```

Load the service:
```bash
launchctl load -w ~/Library/LaunchAgents/com.michaelcli.webcam-capture.plist
```

### 4. Grant Camera Permissions

macOS requires explicit Camera access for the webcam daemon. Without it, ffmpeg will fail with:
```
Failed to create AV capture input device: Cannot use FaceTime HD Camera (Built-in)
Error opening input: Input/output error
```

**Steps:**

1. **Run the daemon manually once from Terminal:**
   ```bash
   /usr/local/bin/webcam-capture-daemon.sh
   ```
   macOS should display a system prompt asking if `ffmpeg` (or `bash`) can access the camera. **Click "Allow".**

2. **Verify in System Settings > Privacy & Security > Camera.** Ensure the following are toggled **ON**:
   - **Terminal** (or **iTerm2**)
   - **/bin/bash** — when the daemon runs via LaunchAgent, macOS TCC attributes the camera request to `bash`, not to `ffmpeg`
   - **ffmpeg** — if it appears in the list

3. **If the permission prompt never appeared**, trigger it manually:
   ```bash
   ffmpeg -f avfoundation -framerate 1 -i 0 -t 1 -y /tmp/test-webcam.mp4
   ```

4. **After granting permissions**, restart the daemon:
   ```bash
   pkill -f webcam-capture-daemon
   ```
   The LaunchAgent will relaunch it automatically.

**Note:** The "Screen Recording" permission (in the same Privacy & Security panel) is separate and only needed for the [Screen Capture Daemon](https://github.com/msmolkin/screen-capture-daemon). The webcam daemon only needs Camera access.

## How It Works

- **`webcam-capture-daemon.sh`**:
   - Automatically finds the "FaceTime HD Camera" device index using `ffmpeg -list_devices`.
   - Starts an `ffmpeg` process to capture at the configured FPS.
   - Re-reads `~/.capture_config` every few seconds to honor pause/resume and FPS changes from the menubar.
   - Saves recordings in `~/screen-recordings/YYYY-MM-DD/webcam-TIMESTAMP.mp4`.
   - Rotates automatically at midnight.

## Notes & Gotchas

- **Restarting:** The LaunchAgent uses `KeepAlive`, so `pkill -f webcam-capture-daemon` is sufficient to restart — launchd relaunches it automatically.
- **Camera permissions after Homebrew upgrades:** When ffmpeg is upgraded via `brew upgrade`, the new binary loses its TCC camera permission. Re-grant Camera access in System Settings after each upgrade.
- **FPS changes:** The webcam FPS can be adjusted from the [CaptureMenuApp](https://github.com/msmolkin/screen-capture-daemon#capturemenuapp-menubar-controller) menubar. Changes are written to `~/.capture_config` as `WEBCAM_FPS=<value>` and take effect on the next recording segment.

## Companion Tool

For a complete setup, check out the [Screen Capture Daemon](https://github.com/msmolkin/screen-capture-daemon), which records all your connected screens in the background and includes the CaptureMenuApp menubar controller.

## Support

If you find this tool useful, consider supporting the development:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/msmolkin)

## License
MIT
