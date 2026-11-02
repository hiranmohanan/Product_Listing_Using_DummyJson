#!/bin/bash
# Script to capture screenshot from connected Android device via ADB

OUTPUT_DIR="screens/android"
mkdir -p "$OUTPUT_DIR"

FILENAME="${1:-screenshot_$(date +%Y%m%d_%H%M%S).png}"
OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"

echo "Capturing screenshot to $OUTPUT_PATH..."
adb exec-out screencap -p > "$OUTPUT_PATH"

if [ -s "$OUTPUT_PATH" ]; then
  echo "Screenshot saved successfully: $OUTPUT_PATH"
else
  echo "Failed to capture screenshot. Ensure adb device is connected and authorized."
  rm -f "$OUTPUT_PATH"
  exit 1
fi
