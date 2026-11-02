#!/bin/bash
# Script to capture screenshot from connected iOS device or iOS Simulator

OUTPUT_DIR="screens/ios"
mkdir -p "$OUTPUT_DIR"

FILENAME="${1:-screenshot_$(date +%Y%m%d_%H%M%S).png}"
OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"

# 1. Check if an iOS Simulator is booted
if xcrun simctl list devices booted 2>/dev/null | grep -q "(Booted)"; then
  echo "Booted iOS Simulator detected. Capturing screenshot..."
  xcrun simctl io booted screenshot "$OUTPUT_PATH"
  if [ -s "$OUTPUT_PATH" ]; then
    echo "Screenshot saved successfully: $OUTPUT_PATH"
    exit 0
  fi
fi

# 2. Check for physical iOS device using devicectl (Xcode 15+)
if command -v xcrun &>/dev/null && xcrun devicectl version &>/dev/null; then
  # Look for connected hardware device (reality != simulated)
  PHYSICAL_DEVICE_ID=$(xcrun devicectl list devices 2>/dev/null | awk '$4 == "connected" && $6 != "simulated" {print $3}' | head -n 1)
  if [ -n "$PHYSICAL_DEVICE_ID" ]; then
    echo "Physical iOS device detected ($PHYSICAL_DEVICE_ID). Capturing screenshot..."
    xcrun devicectl device capture screenshot --device "$PHYSICAL_DEVICE_ID" --destination "$OUTPUT_PATH"
    if [ -s "$OUTPUT_PATH" ]; then
      echo "Screenshot saved successfully: $OUTPUT_PATH"
      exit 0
    fi
  fi
fi

# 3. Fallback: Check for idevicescreenshot (libimobiledevice)
if command -v idevicescreenshot &>/dev/null; then
  echo "Capturing screenshot using idevicescreenshot..."
  idevicescreenshot "$OUTPUT_PATH"
  if [ -s "$OUTPUT_PATH" ]; then
    echo "Screenshot saved successfully: $OUTPUT_PATH"
    exit 0
  fi
fi

echo "Error: No booted iOS Simulator or connected physical iOS device found."
echo "Tips:"
echo "  - Start an iOS simulator: open -a Simulator"
echo "  - Or connect an iOS device with Developer Mode enabled and trust this Mac."
rm -f "$OUTPUT_PATH"
exit 1
