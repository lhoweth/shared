#!/bin/bash

# 1. Grab the current desktop image dynamically
CURRENT_WALLPAPER=$(osascript -e 'tell application "System Events" to tell every desktop to get picture' | tr -d '\n' | sed 's/,$//')

if [[ -z "$CURRENT_WALLPAPER" || ! -f "$CURRENT_WALLPAPER" ]]; then
    echo "Error: Could not retrieve current wallpaper path."
    exit 1
fi

echo "Source: $CURRENT_WALLPAPER"

# 2. Setup Variables
USER_UUID=$(dscl . -read /Users/$(whoami) GeneratedUID | awk '{print $2}')
ADMIN_CACHE="/Library/Caches/com.apple.desktop.admin.png"
UUID_DIR="/Library/Caches/Desktop Pictures/$USER_UUID"
UUID_CACHE="$UUID_DIR/lockscreen.png"

# 3. Unlock existing files so we can overwrite them
echo "Unlocking existing caches..."
sudo chflags nouchg "$ADMIN_CACHE" 2>/dev/null
sudo chflags nouchg "$UUID_CACHE" 2>/dev/null

# 4. Ensure directories exist
sudo mkdir -p "$UUID_DIR"

# 5. Inject the new image
echo "Converting and injecting..."
sudo sips -s format png "$CURRENT_WALLPAPER" --out "$ADMIN_CACHE" > /dev/null
sudo cp "$ADMIN_CACHE" "$UUID_CACHE"

# 6. Set Permissions and Lock 'em down
# This prevents the OS from "reverting" to default on a whim
echo "Locking files with immutable flag..."
sudo chmod 644 "$ADMIN_CACHE" "$UUID_CACHE"
sudo chflags uchg "$ADMIN_CACHE"
sudo chflags uchg "$UUID_CACHE"

# 7. Final Sync to the Boot Partition
echo "Baking changes into Preboot volume..."
sudo diskutil apfs updatePreboot /

echo "--- Process Complete: Login screen synced and locked. ---"

