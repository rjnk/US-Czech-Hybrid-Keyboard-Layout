#!/bin/bash
# Uninstallation script for us_czech_hybrid keyboard layout
# Run as root or with sudo

set -e

XKB_DIR="/usr/share/X11/xkb"
SYMBOLS_DIR="${XKB_DIR}/symbols"
RULES_DIR="${XKB_DIR}/rules"

echo "Uninstalling us_czech_hybrid keyboard layout..."

# Remove the symbols file
if [ -f "${SYMBOLS_DIR}/us_czech_hybrid" ]; then
    rm "${SYMBOLS_DIR}/us_czech_hybrid"
    echo "  Removed symbols file"
fi

# Remove from evdev.xml
if grep -q "us_czech_hybrid" "${RULES_DIR}/evdev.xml"; then
    # Clean approach: use a temp file
    python3 -c "
import re
with open('${RULES_DIR}/evdev.xml', 'r') as f:
    content = f.read()
pattern = r'\s*<layout>\s*<configItem>\s*<name>us_czech_hybrid</name>.*?</layout>'
content = re.sub(pattern, '', content, flags=re.DOTALL)
with open('${RULES_DIR}/evdev.xml', 'w') as f:
    f.write(content)
"
    echo "  Removed from evdev.xml"
fi

# Remove from evdev.lst
if grep -q "us_czech_hybrid" "${RULES_DIR}/evdev.lst"; then
    sed -i '/us_czech_hybrid/d' "${RULES_DIR}/evdev.lst"
    echo "  Removed from evdev.lst"
fi

echo ""
echo "Uninstallation complete!"
echo "You may need to log out and back in for changes to take effect."
