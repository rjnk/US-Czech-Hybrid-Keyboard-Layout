#!/bin/bash
# Uninstallation script for us_czech_hybrid keyboard layout on GNOME/Wayland
# Run as your normal user (DO NOT run as root)

set -e

if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. Run it as your normal user."
  exit 1
fi

XKB_DIR="$HOME/.config/xkb"
SYMBOLS_DIR="${XKB_DIR}/symbols"

echo "Uninstalling us_czech_hybrid keyboard layout..."

# Remove the symbols file
if [ -f "${SYMBOLS_DIR}/us_czech_hybrid" ]; then
    rm "${SYMBOLS_DIR}/us_czech_hybrid"
    echo "  Removed symbols file from ${SYMBOLS_DIR}"
else
    echo "  Symbols file not found in ${SYMBOLS_DIR}"
fi

# Remove from GNOME input sources
echo "  Updating GNOME input sources..."
CURRENT_SOURCES=$(gsettings get org.gnome.desktop.input-sources sources)

if echo "$CURRENT_SOURCES" | grep -q "'us_czech_hybrid'"; then
    # Use python to cleanly remove the tuple from the gsettings array string
    NEW_SOURCES=$(python3 -c "
import ast
sources_str = \"$CURRENT_SOURCES\".replace('@a(ss) ', '')
try:
    sources = ast.literal_eval(sources_str)
    sources = [s for s in sources if s[1] != 'us_czech_hybrid']
    print(str(sources))
except Exception as e:
    print(sources_str)
")
    gsettings set org.gnome.desktop.input-sources sources "$NEW_SOURCES"
    echo "  Removed layout from GNOME settings."
else
    echo "  Layout was not found in GNOME settings."
fi

echo ""
echo "Uninstallation complete!"
