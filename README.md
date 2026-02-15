# Lee's Command Center

This repository is the "Source of Truth" for my terminal environment, 
optimized for macOS and Linux.

-----------------------------------------------------------------------
CORE FILES
-----------------------------------------------------------------------
- OhMyZshSetup.sh  : Master installer (dependencies, fonts, shell theme)
- ghostty_config   : Master Ghostty settings (140x40, Agnoster-ready)
- Network_Config   : Reference of home network architecture

-----------------------------------------------------------------------
NEW MACHINE SETUP
-----------------------------------------------------------------------
1. Clone the repo to the standard path:
   mkdir -p ~/Downloads && cd ~/Downloads
   git clone https://github.com/lhoweth/shared.git

2. Authenticate with GitHub CLI:
   brew install gh && gh auth login

3. Run the Installer:
   cd ~/Downloads/shared
   chmod +x OhMyZshSetup.sh
   ./OhMyZshSetup.sh

4. Restart Terminal (or run: source ~/.zshrc)

-----------------------------------------------------------------------
WORKFLOW: dotsync
-----------------------------------------------------------------------
Do not edit system configs directly. 
1. Edit files in ~/Downloads/shared/
2. Run 'dotsync' from any directory.
   - Automatically pulls, commits local edits, and pushes to GitHub.
-----------------------------------------------------------------------
