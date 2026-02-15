#!/bin/bash

# 1. Setup Directory
SHADER_DIR="$HOME/.config/ghostty/shaders"
# Target the file in the shared folder directly since it's symlinked
CONFIG_FILE="$HOME/Downloads/shared/ghostty_config"

mkdir -p "$SHADER_DIR"

# 2. Clone or Update the Shaders
if [ -d "$SHADER_DIR/.git" ]; then
    echo "Updating shaders..."
    git -C "$SHADER_DIR" pull
else
    echo "Cloning shaders..."
    git clone https://github.com/m-ahdal/ghostty-shaders.git "$SHADER_DIR"
fi

# 3. Clean up existing custom-shader lines and the header
# We also strip trailing empty lines to prevent "gap creep"
grep -v "custom-shader" "$CONFIG_FILE" | grep -v -e "--- Available Shaders ---" | sed -e :a -e '/^\n*$/{$d;N;ba' -e '}' > "${CONFIG_FILE}.tmp" && mv "${CONFIG_FILE}.tmp" "$CONFIG_FILE"

# 4. Append all found shaders as commented-out options
echo -e "\n# --- Available Shaders ---" >> "$CONFIG_FILE"
ls "$SHADER_DIR" | grep '\.glsl$' | while read -r shader; do
    echo "# custom-shader = shaders/$shader" >> "$CONFIG_FILE"
done

echo "Done! Shaders refreshed in $CONFIG_FILE"
