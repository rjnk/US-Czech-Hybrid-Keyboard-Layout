#!/bin/bash
# Installation script for us_czech_hybrid keyboard layout
# Run as root or with sudo

set -e

XKB_DIR="/usr/share/X11/xkb"
SYMBOLS_DIR="${XKB_DIR}/symbols"
RULES_DIR="${XKB_DIR}/rules"

echo "Installing us_czech_hybrid keyboard layout..."

# Install the symbols file
install -m 644 us_czech_hybrid "${SYMBOLS_DIR}/us_czech_hybrid"
echo "  Installed symbols file"

# Backup and patch evdev.xml if not already patched
if ! grep -q "us_czech_hybrid" "${RULES_DIR}/evdev.xml"; then
    cp "${RULES_DIR}/evdev.xml" "${RULES_DIR}/evdev.xml.backup"
    # Insert before the closing </layoutList> tag
    sed -i '/<\/layoutList>/i \
    <layout>\
      <configItem>\
        <name>us_czech_hybrid</name>\
        <shortDescription>enCZ</shortDescription>\
        <description>English (US-Czech hybrid)</description>\
        <languageList>\
          <iso639Id>eng</iso639Id>\
          <iso639Id>ces</iso639Id>\
        </languageList>\
      </configItem>\
    </layout>' "${RULES_DIR}/evdev.xml"
    echo "  Patched evdev.xml"
else
    echo "  evdev.xml already contains us_czech_hybrid entry"
fi

# Backup and patch evdev.lst if not already patched
if ! grep -q "us_czech_hybrid" "${RULES_DIR}/evdev.lst"; then
    cp "${RULES_DIR}/evdev.lst" "${RULES_DIR}/evdev.lst.backup"
    # Add to the layout section
    sed -i '/^! layout$/a\  us_czech_hybrid       English (US-Czech hybrid)' "${RULES_DIR}/evdev.lst"
    echo "  Patched evdev.lst"
else
    echo "  evdev.lst already contains us_czech_hybrid entry"
fi

echo ""
echo "Installation complete!"
echo "You may need to log out and back in, or run:"
echo "  gsettings reset org.gnome.desktop.input-sources sources"
echo "Then add the layout from GNOME Settings > Keyboard > Input Sources"
