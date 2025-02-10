#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Flag for quiet mode
QUIET=false

# Parse command line arguments
while getopts "q" opt; do
  case $opt in
  q)
    QUIET=true
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  esac
done

# Function to prompt for confirmation
confirm() {
  if [ "$QUIET" = true ]; then
    return 0
  fi

  read -p "${1} [Y/n] " response
  response=${response:-Y}
  if [[ $response =~ ^[Yy]$ ]]; then
    return 0
  else
    return 1
  fi
}

# Function to print status messages
print_status() {
  echo -e "${GREEN}==>${NC} ${1}"
}

# Function to print error messages
print_error() {
  echo -e "${RED}Error:${NC} ${1}"
}

# Check for Xcode Command Line Tools
print_status "Checking for Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  if confirm "Xcode Command Line Tools not found. Install?"; then
    xcode-select --install
    print_status "Please wait for Xcode Command Line Tools to finish installing, then press any key to continue..."
    read -n 1
  else
    print_error "Xcode Command Line Tools are required. Exiting."
    exit 1
  fi
fi

# Check for Homebrew
print_status "Checking for Homebrew..."
if ! command -v brew &>/dev/null; then
  if confirm "Homebrew not found. Install?"; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    print_status "Homebrew installed successfully"
  else
    print_error "Homebrew is required. Exiting."
    exit 1
  fi
fi

# Update .zshenv
ZSHENV_PATH="$HOME/.zshenv"
XDG_CONFIG_HOME="$HOME/.config/"

# make sure to escape quotes and $
ZSHENV_CONTENTS="
# Added by dotfiles setup
# set XDG directories
if [[ -z \"\$XDG_CONFIG_HOME\" ]]
then
        export XDG_CONFIG_HOME="\$HOME/.config/"
fi
if [[ -z \"\$XDG_DATA_HOME\" ]]
then
        export XDG_DATA_HOME=\"\$HOME/.local/share/\"
fi
if [[ -z \"\$XDG_CACHE_HOME\" ]]
then
        export XDG_CACHE_HOME=\"\$HOME/.cache/\"
fi
# set location of .zshrc if present
if [[ -d \"\$XDG_CONFIG_HOME/zsh\" ]]
then
        export ZDOTDIR=\"\$XDG_CONFIG_HOME/zsh/\"
fi

# Hombrew path
export PATH=\"/opt/homebrew/bin:\$PATH\"
export HOMEBREW_BREWFILE=\"\$XDG_CONFIG_HOME/homebrew/Brewfile\"
# End dotfiles setup
"

print_status "Checking .zshenv configuration..."
if [ ! -f "$ZSHENV_PATH" ]; then
  touch "$ZSHENV_PATH"
  print_status "No .zshenv found in $HOME, made a fresh one."
fi

print_status "Checking .zshenv configuration..."
if ! grep -q "Added by dotfiles setup" "$ZSHENV_PATH" 2>/dev/null; then
  if confirm "Append environment variables to .zshenv?"; then
    echo "$ZSHENV_CONTENTS" >>"$ZSHENV_PATH"
    print_status "Updated .zshenv successfully. Be sure to re-source zsh."
  fi
fi

# Install Homebrew packages
print_status "Checking Homebrew packages..."
if [ -f "$XDG_CONFIG_HOME/homebrew/Brewfile" ]; then
  if confirm "Install packages from Brewfile?"; then
    brew bundle --file="$XDG_CONFIG_HOME/homebrew/Brewfile"
    print_status "Homebrew packages installed successfully"
  fi
else
  print_error "Brewfile not found"
fi

if [ -f "$XDG_CONFIG_HOME/homebrew/Brewfile.work" ]; then
  if confirm "Install packages from Brewfile.work?"; then
    brew bundle --file="$XDG_CONFIG_HOME/homebrew/Brewfile.work"
    print_status "Homebrew packages installed successfully"
  fi
else
  print_error "Brewfile.work not found"
fi

print_status "Setup completed successfully!"
