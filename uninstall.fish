#!/usr/bin/env fish

# Check for root / sudo privileges
if not test (id -u) -eq 0
    echo "Error: This script must be run with root privileges." >&2
    echo "Please run: sudo ./uninstall.fish" >&2
    exit 1
end

set SYMBOLS_DIR "/usr/share/X11/xkb/symbols"
set RULES_DIR "/usr/share/X11/xkb/rules"
set TARGET_SYMBOL "$SYMBOLS_DIR/us_czech_hybrid"
set US_SYMBOL "$SYMBOLS_DIR/us"

echo "==> 1. Removing standalone keyboard layout symbols file..."
if test -f "$TARGET_SYMBOL"
    rm -f "$TARGET_SYMBOL"
    echo "    Removed $TARGET_SYMBOL"
else
    echo "    $TARGET_SYMBOL not found."
end

echo "==> 2. Removing hybrid variants from $US_SYMBOL..."
python3 -c "
import sys, os, re

us_file = sys.argv[1]
if os.path.exists(us_file):
    with open(us_file, 'r', encoding='utf-8') as f:
        content = f.read()

    if '// US-Czech hybrid layout' in content:
        pattern = re.compile(r'\n// US-Czech hybrid layout\n.*', re.DOTALL)
        new_content = pattern.sub('', content)
        with open(us_file, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f'    Removed hybrid variants from {us_file}')
    else:
        print(f'    Hybrid variants not present in {us_file}')
" "$US_SYMBOL"

echo "==> 3. Removing layout entries from XKB rule XML files..."
python3 -c "
import sys, os, re

xml_files = [p for p in sys.argv[1:] if os.path.exists(p)]
processed_inodes = set()

pattern_layout = re.compile(r'    <layout>\s*<configItem>\s*<name>us_czech_hybrid</name>.*?</layout>\s*\n', re.DOTALL)
pattern_variant = re.compile(r'\s*<variant>\s*<configItem>\s*<name>(?:cz_hybrid|us_czech_hybrid)</name>.*?</variant>', re.DOTALL)

for filepath in xml_files:
    try:
        st = os.stat(filepath)
        if st.st_ino in processed_inodes:
            continue
        processed_inodes.add(st.st_ino)

        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        modified = False

        if '<name>us_czech_hybrid</name>' in content or '<name>cz_hybrid</name>' in content:
            content = pattern_layout.sub('', content)
            content = pattern_variant.sub('', content)
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'    Removed layout entries from {filepath}')
        else:
            print(f'    Layout entries not present in {filepath}')
    except Exception as e:
        print(f'    Error updating {filepath}: {e}', file=sys.stderr)
" "$RULES_DIR/evdev.xml" "$RULES_DIR/base.xml" "$RULES_DIR/evdev.extras.xml" "$RULES_DIR/base.extras.xml"

echo "==> 4. Removing layout entries from XKB rule LST files..."
python3 -c "
import sys, os

lst_files = [p for p in sys.argv[1:] if os.path.exists(p)]
processed_inodes = set()

for filepath in lst_files:
    try:
        st = os.stat(filepath)
        if st.st_ino in processed_inodes:
            continue
        processed_inodes.add(st.st_ino)

        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()

        new_lines = [line for line in lines if 'us_czech_hybrid' not in line and 'cz_hybrid' not in line]

        if len(new_lines) != len(lines):
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(new_lines)
            print(f'    Removed layout entries from {filepath}')
        else:
            print(f'    Layout entries not present in {filepath}')
    except Exception as e:
        print(f'    Error updating {filepath}: {e}', file=sys.stderr)
" "$RULES_DIR/evdev.lst" "$RULES_DIR/base.lst" "$RULES_DIR/evdev.extras.lst" "$RULES_DIR/base.extras.lst"

echo ""
echo "Uninstallation complete!"
