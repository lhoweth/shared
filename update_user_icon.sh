#!/bin/bash
set -euo pipefail

# --- Configuration ---
# Set the desired icon size. 256x256 is a standard for high-resolution icons.
TARGET_SIZE="256x256"

# Get the path to the current wallpaper. gsettings wraps the output in single quotes.
WALLPAPER_URI=$(gsettings get org.gnome.desktop.background picture-uri)

# Use parameter expansion to strip the surrounding single quotes and 'file://' prefix.
WALLPAPER_PATH="${WALLPAPER_URI#\'file://}"
WALLPAPER_PATH="${WALLPAPER_PATH%\'}"

# Get the current username
USERNAME=$(whoami)

# The user icon is stored in a secure system directory
ACCOUNTS_SERVICE_ICON_DIR="/var/lib/AccountsService/icons"

# Temporary icon file name for the resized image
TEMP_ICON_FILE="/tmp/${USERNAME}_icon.png"

# --- Script Logic ---

# Check if the wallpaper file exists
if [ ! -f "$WALLPAPER_PATH" ]; then
    echo "Error: Wallpaper file not found at '$WALLPAPER_PATH'"
    exit 1
fi

# Check for imagemagick dependency
if ! command -v convert &> /dev/null; then
    echo "Error: 'imagemagick' is not installed. Please install it with 'sudo apt install imagemagick' or similar."
    exit 1
fi

# Resize and crop the image for the highest possible quality
convert "$WALLPAPER_PATH" \
    -filter LanczosSharp \
    -resize "${TARGET_SIZE}^" \
    -gravity Center \
    -extent "$TARGET_SIZE" \
    -unsharp 0.25x0.08+8.3+0.05 \
    -define png:compression-level=9 \
    -define png:compression-filter=5 \
    -define png:compression-strategy=1 \
    -quality 100 \
    "$TEMP_ICON_FILE"

# Use sudo to copy the image to the secure AccountsService directory
sudo cp "$TEMP_ICON_FILE" "${ACCOUNTS_SERVICE_ICON_DIR}/${USERNAME}"

# Remove the temporary file
rm "$TEMP_ICON_FILE"

# Update AccountsService to use the new icon
busctl call \
    org.freedesktop.Accounts \
    "/org/freedesktop/Accounts/User$(id -u)" \
    org.freedesktop.Accounts.User \
    SetIconFile \
    s "/var/lib/AccountsService/icons/${USERNAME}" > /dev/null

echo "User icon updated to match the current wallpaper."

