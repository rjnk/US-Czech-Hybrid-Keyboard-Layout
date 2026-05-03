#!/bin/bash
# Installation script for us_czech_hybrid keyboard layout on GNOME/Wayland
# Run as your normal user (DO NOT run as root)

set -e

if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. Run it as your normal user."
  exit 1
fi

XKB_DIR="$HOME/.config/xkb"
SYMBOLS_DIR="${XKB_DIR}/symbols"

echo "Installing us_czech_hybrid keyboard layout for Wayland..."

# 1. Create the user-local XKB directory structure
mkdir -p "$SYMBOLS_DIR"

# 2. Copy the symbols file
cp us_czech_hybrid "${SYMBOLS_DIR}/us_czech_hybrid"
echo "  Installed symbols file to ${SYMBOLS_DIR}/us_czech_hybrid"

# 3. Add to GNOME input sources
echo "  Updating GNOME input sources..."

# Get current sources
CURRENT_SOURCES=$(gsettings get org.gnome.desktop.input-sources sources)

# Check if it's already in the sources
if echo "$CURRENT_SOURCES" | grep -q "'us_czech_hybrid'"; then
    echo "  Layout is already present in GNOME settings."
else
    # If sources is empty or just @a(ss) []
    if [ "$CURRENT_SOURCES" = "@a(ss) []" ]; then
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us_czech_hybrid')]"
    else
        # Append to existing sources
        NEW_SOURCES=$(echo "$CURRENT_SOURCES" | sed "s/]/, ('xkb', 'us_czech_hybrid')]/")
        gsettings set org.gnome.desktop.input-sources sources "$NEW_SOURCES"
    fi
    echo "  Added layout to GNOME settings."
fi

# Enable showing all sources if it's hidden in UI (useful for some versions of GNOME)
gsettings set org.gnome.desktop.input-sources show-all-sources true

echo ""
echo "Installation complete!"
echo "The layout is installed locally for your user."
echo "You can manage it in Settings > Keyboard > Input Sources."
