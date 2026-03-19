# Webcam Capture Daemon for macOS

A lightweight, automated background webcam capture system for macOS that records your FaceTime HD Camera (or any default camera) at 1 FPS.

Designed to be a "set and forget" companion to the [screen capture daemon](https://github.com/msmolkin/screen-capture-daemon), it allows you to have a low-framerate video log of your webcam for reference.

## Features

- **Automated Capture:** Records at 1 FPS by default (configurable).
- **Background Operation:** Runs as a macOS LaunchAgent.
- **Robustness:** Handles system sleep/wake and automatic daily rotation.
- **Low Impact:** Captures at 640px wide with high compression to minimize CPU and disk usage.

## Installation

### 1. Requirements

- **macOS**
- **ffmpeg** (Install via Homebrew: `brew install ffmpeg`)

### 2. Setup Script

Copy the script to a location in your `PATH` (e.g., `/usr/local/bin/`):

```bash
cp webcam-capture-daemon.sh /usr/local/bin/
chmod +x /usr/local/bin/webcam-capture-daemon.sh
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

### 4. Grant Permissions

macOS requires explicit permission for an application to access the camera:
1. When the daemon first runs, you should see a system prompt asking if `ffmpeg` can access the camera.
2. **Click "Allow".**
3. You can verify permissions in **System Settings > Privacy & Security > Camera**.

## How It Works

- **`webcam-capture-daemon.sh`**:
   - Automatically finds the "FaceTime HD Camera" device index using `ffmpeg -list_devices`.
   - Starts an `ffmpeg` process to capture at 1 FPS.
   - Saves recordings in `~/screen-recordings/YYYY-MM-DD/webcam-TIMESTAMP.mp4`.
   - Rotates automatically at midnight.

## Companion Tool

For a complete setup, check out the [Screen Capture Daemon](https://github.com/msmolkin/screen-capture-daemon), which records all your connected screens in the background.

## Support

If you find this tool useful, consider supporting the development:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/msmolkin)

## License
MIT
