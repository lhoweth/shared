# Lee's Command Center

This repository is the "Source of Truth" for my terminal environment, 
optimized for macOS and Linux.

-----------------------------------------------------------------------
CORE FILES
-----------------------------------------------------------------------
- OhMyZshSetup.sh  : Master installer (dependencies, fonts, shell theme)
- ghostty_config   : Master Ghostty settings (Shaders, Opacity, Agnoster-ready)

-----------------------------------------------------------------------
NEW MACHINE SETUP
-----------------------------------------------------------------------
1. Clone the repo to the standard path:
   mkdir -p ~/Downloads && cd ~/Downloads
   git clone https://github.com/lhoweth/shared.git

2. Run the Installer:
   cd ~/Downloads/shared
   ./OhMyZshSetup.sh

3. Restart Terminal (or run: source ~/.zshrc)

-----------------------------------------------------------------------
WORKFLOW: dotsync
-----------------------------------------------------------------------
Do not edit system configs directly. 
1. Edit files in ~/Downloads/shared/
2. Run 'dotsync' from any directory.
   - Automatically pulls, commits local edits, and pushes to GitHub.
-----------------------------------------------------------------------
