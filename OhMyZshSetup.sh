#!/bin/bash

# Formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}==> Initiating High-Performance Terminal Setup...${NC}"

# 0. Pre-Flight: GitHub Authentication
if ! command -v gh >/dev/null; then
    echo "GitHub CLI (gh) not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then brew install gh; else sudo apt-get update && sudo apt-get install -y gh; fi
fi

if ! gh auth status >/dev/null 2>&1; then
    echo -e "${BLUE}==> Authenticating with GitHub...${NC}"
    gh auth login
else
    echo -e "${GREEN}==> GitHub Authenticated.${NC}"
fi

# 1. Dependency Installer (fzf, bat, chafa, file)
install_pkg() {
    if command -v brew >/dev/null; then brew install "$@";
    elif command -v apt-get >/dev/null; then sudo apt-get update && sudo apt-get install -y "$@";
    elif command -v dnf >/dev/null; then sudo dnf install -y "$@";
    elif command -v pacman >/dev/null; then sudo pacman -S --noconfirm "$@";
    else echo "Package manager not found. Install $@ manually."; fi
}

echo "Checking dependencies..."
for pkg in fzf bat chafa file git curl; do
    command -v $pkg >/dev/null || { echo "Installing $pkg..."; install_pkg $pkg; }
done

# 2. Oh My Zsh Core
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 3. Custom Plugins & Fonts
ZSH_CUSTOM_PLUGINS="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
PLUGINS=(
    "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
)

for item in "${PLUGINS[@]}"; do
    NAME="${item%%|*}"
    URL="${item#*|}"
    [ ! -d "$ZSH_CUSTOM_PLUGINS/$NAME" ] && git clone "$URL" "$ZSH_CUSTOM_PLUGINS/$NAME"
done

# Portable Font Installer (Meslo Nerd Font)
if [[ "$OSTYPE" == "darwin"* ]]; then
    FONT_DIR="$HOME/Library/Fonts"
else
    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"
fi

if [ ! -f "$FONT_DIR/MesloLGS NF Regular.ttf" ]; then
    echo "Downloading Meslo Nerd Fonts for Agnoster..."
    for variant in Regular Bold Italic "Bold Italic"; do
        file_name="MesloLGS%20NF%20${variant// /%20}.ttf"
        curl -L -s -o "$FONT_DIR/MesloLGS NF $variant.ttf" "https://github.com/romkatv/dotfiles-bin/raw/master/$file_name"
    done
    command -v fc-cache >/dev/null && fc-cache -f "$FONT_DIR"
fi

# 4. Surgical .zshrc Updates
echo -e "${GREEN}Applying configuration surgery...${NC}"

sed -i '' 's/^ZSH_THEME=".*"/ZSH_THEME="agnoster"/' "$HOME/.zshrc" 2>/dev/null || \
sed -i 's/^ZSH_THEME=".*"/ZSH_THEME="agnoster"/' "$HOME/.zshrc"

sed -i '' 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc" 2>/dev/null || \
sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"

# 5. Injecting the Working FZF Alias & Git Sync Alias
if ! grep -q "alias dotsync=" "$HOME/.zshrc"; then
    cat << 'EOF' >> "$HOME/.zshrc"

# --- Power FZF Previewer ---
alias fzf="fzf --preview 'printf \"\033[2J\033_Gi=1,a=d\033\\\\\"; mime=\$(file --mime-type -b {}); if [[ \$mime == image/* ]]; then chafa -s 50x30 {}; else bat --color=always --style=numbers {} 2>/dev/null || cat {}; fi'"

# --- Quick Dotfile Sync ---
alias dotsync="git -C $HOME/Downloads/shared add . && git -C $HOME/Downloads/shared commit -m 'Update configs' && git -C $HOME/Downloads/shared pull --rebase && git -C $HOME/Downloads/shared push"
EOF
fi

# 6. Ghostty Installation & Configuration (Cross-Platform)
if ! command -v ghostty >/dev/null; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "Installing Ghostty via Homebrew Cask..."
        brew install --cask ghostty
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "Installing Ghostty via Snap..."
        if command -v snap >/dev/null; then
            sudo snap install ghostty --classic
        else
            echo "Snap not found. Please install Ghostty manually for your distro."
        fi
    fi
fi

# 7. Symlink Logic for Dotfiles Repo
# Hardcoded to your shared directory for portability
REPO_DIR="$HOME/Downloads/shared"
GHOSTTY_TARGET="$HOME/.config/ghostty/config"

if [ -d "$REPO_DIR/.git" ]; then
    echo -e "${BLUE}Git repo detected at $REPO_DIR. Establishing symlinks...${NC}"
    mkdir -p "$HOME/.config/ghostty"
    
    # If a real file exists, back it up before replacing with a symlink
    if [ -f "$GHOSTTY_TARGET" ] && [ ! -L "$GHOSTTY_TARGET" ]; then
        mv "$GHOSTTY_TARGET" "${GHOSTTY_TARGET}.bak"
    fi

    if [ -f "$REPO_DIR/ghostty_config" ]; then
        ln -sf "$REPO_DIR/ghostty_config" "$GHOSTTY_TARGET"
        echo "Linked ghostty_config -> $GHOSTTY_TARGET"
    else
        # Fallback: Create initial config in repo if it doesn't exist
        cat << 'EOF' > "$REPO_DIR/ghostty_config"
font-family = "MesloLGS NF"
window-decoration = true
background-opacity = 0.85
background-blur-radius = 20
window-width = 140
window-height = 40
EOF
        ln -sf "$REPO_DIR/ghostty_config" "$GHOSTTY_TARGET"
    fi
else
    # Non-repo fallback: Create config directly
    mkdir -p ~/.config/ghostty
    cat << 'EOF' > "$GHOSTTY_TARGET"
font-family = "MesloLGS NF"
window-decoration = true
background-opacity = 0.85
background-blur-radius = 20
window-width = 140
window-height = 40
EOF
fi

echo -e "${GREEN}Setup Complete!${NC}"
echo "Note: Ensure you are using Meslo Nerd Font (or similar) for Agnoster symbols."

