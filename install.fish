#!/usr/bin/env fish

# Check for root / sudo privileges
if not test (id -u) -eq 0
    echo "Error: This script must be run with root privileges." >&2
    echo "Please run: sudo ./install.fish" >&2
    exit 1
end

set SCRIPT_DIR (cd (dirname (status filename)); and pwd)
set LAYOUT_FILE "$SCRIPT_DIR/us_czech_hybrid"
set SYMBOLS_DIR "/usr/share/X11/xkb/symbols"
set RULES_DIR "/usr/share/X11/xkb/rules"
set TARGET_SYMBOL "$SYMBOLS_DIR/us_czech_hybrid"
set US_SYMBOL "$SYMBOLS_DIR/us"

if not test -f "$LAYOUT_FILE"
    echo "Error: Layout file '$LAYOUT_FILE' does not exist." >&2
    exit 1
end

echo "==> 1. Installing standalone keyboard layout symbols file..."
cp "$LAYOUT_FILE" "$TARGET_SYMBOL"
chmod 644 "$TARGET_SYMBOL"
echo "    Copied to $TARGET_SYMBOL"

echo "==> 2. Appending US variants to $US_SYMBOL..."
python3 -c "
import sys, os

us_file = sys.argv[1]
if os.path.exists(us_file):
    with open(us_file, 'r', encoding='utf-8') as f:
        content = f.read()

    if '// US-Czech hybrid layout' not in content:
        snippet = '''
// US-Czech hybrid layout
partial alphanumeric_keys
xkb_symbols \"cz_hybrid\" {
    name[Group1] = \"English (US-Czech hybrid)\";
    include \"us(basic)\"
    key <AE01> { [ dead_caron,      exclam,    1,  NoSymbol ] };
    key <AE02> { [ ecaron,          at,        2,  NoSymbol ] };
    key <AE03> { [ scaron,          numbersign, 3, NoSymbol ] };
    key <AE04> { [ ccaron,          dollar,    4,  NoSymbol ] };
    key <AE05> { [ rcaron,          percent,   5,  NoSymbol ] };
    key <AE06> { [ zcaron,          asciicircum, 6, NoSymbol ] };
    key <AE07> { [ yacute,          ampersand, 7,  NoSymbol ] };
    key <AE08> { [ aacute,          asterisk,  8,  NoSymbol ] };
    key <AE09> { [ iacute,          parenleft, 9,  NoSymbol ] };
    key <AE10> { [ dead_acute,      parenright, 0, NoSymbol ] };
    key <AC10> { [ semicolon,       colon,      uring, NoSymbol ] };
    include \"level3(ralt_switch)\"
};

partial alphanumeric_keys
xkb_symbols \"us_czech_hybrid\" {
    include \"us(cz_hybrid)\"
};
'''
        with open(us_file, 'a', encoding='utf-8') as f:
            f.write(snippet)
        print(f'    Appended hybrid variants to {us_file}')
    else:
        print(f'    Variants already present in {us_file}')
" "$US_SYMBOL"

echo "==> 3. Updating XKB rule XML files..."
python3 -c "
import sys, os, re

xml_files = [p for p in sys.argv[1:] if os.path.exists(p)]
processed_inodes = set()

layout_snippet = '''    <layout>
      <configItem>
        <name>us_czech_hybrid</name>
        <shortDescription>enCZ</shortDescription>
        <description>English (US-Czech hybrid)</description>
        <languageList>
          <iso639Id>eng</iso639Id>
          <iso639Id>ces</iso639Id>
        </languageList>
      </configItem>
      <variantList/>
    </layout>
'''

variant_snippet = '''        <variant>
          <configItem>
            <name>cz_hybrid</name>
            <description>English (US-Czech hybrid)</description>
            <languageList>
              <iso639Id>eng</iso639Id>
              <iso639Id>ces</iso639Id>
            </languageList>
          </configItem>
        </variant>
        <variant>
          <configItem>
            <name>us_czech_hybrid</name>
            <description>English (US-Czech hybrid)</description>
            <languageList>
              <iso639Id>eng</iso639Id>
              <iso639Id>ces</iso639Id>
            </languageList>
          </configItem>
        </variant>
'''

for filepath in xml_files:
    try:
        st = os.stat(filepath)
        if st.st_ino in processed_inodes:
            continue
        processed_inodes.add(st.st_ino)

        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        modified = False

        # Add variants under layout 'us'
        if '<name>cz_hybrid</name>' not in content:
            pattern_us = re.compile(r'(<name>us</name>.*?<variantList>)', re.DOTALL)
            if pattern_us.search(content):
                content = pattern_us.sub(r'\1\n' + variant_snippet, content, count=1)
                modified = True

        # Add top-level layout 'us_czech_hybrid'
        if '<name>us_czech_hybrid</name>' not in content:
            if '</layoutList>' in content:
                content = content.replace('</layoutList>', layout_snippet + '  </layoutList>', 1)
                modified = True

        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'    Successfully updated {filepath}')
        else:
            print(f'    Layout entries already registered in {filepath}')
    except Exception as e:
        print(f'    Error updating {filepath}: {e}', file=sys.stderr)
" "$RULES_DIR/evdev.xml" "$RULES_DIR/base.xml" "$RULES_DIR/evdev.extras.xml" "$RULES_DIR/base.extras.xml"

echo "==> 4. Updating XKB rule LST files..."
python3 -c "
import sys, os

lst_files = [p for p in sys.argv[1:] if os.path.exists(p)]
processed_inodes = set()

layout_line = '  us_czech_hybrid English (US-Czech hybrid)\n'
variant_line1 = '  cz_hybrid       us: English (US-Czech hybrid)\n'
variant_line2 = '  us_czech_hybrid us: English (US-Czech hybrid)\n'

for filepath in lst_files:
    try:
        st = os.stat(filepath)
        if st.st_ino in processed_inodes:
            continue
        processed_inodes.add(st.st_ino)

        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        if 'us_czech_hybrid' in content and 'cz_hybrid' in content:
            print(f'    Layout already listed in {filepath}')
            continue

        lines = content.splitlines(keepends=True)
        new_lines = []
        in_layout = False
        in_variant = False
        inserted_layout = False
        inserted_variant = False

        for line in lines:
            new_lines.append(line)
            if line.strip() == '! layout':
                in_layout = True
                in_variant = False
            elif line.strip() == '! variant':
                in_variant = True
                in_layout = False

            if in_layout and not inserted_layout and 'us_czech_hybrid' not in content:
                new_lines.append(layout_line)
                inserted_layout = True

            if in_variant and not inserted_variant and 'cz_hybrid' not in content:
                new_lines.append(variant_line1)
                new_lines.append(variant_line2)
                inserted_variant = True

        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(new_lines)
        print(f'    Successfully updated {filepath}')
    except Exception as e:
        print(f'    Error updating {filepath}: {e}', file=sys.stderr)
" "$RULES_DIR/evdev.lst" "$RULES_DIR/base.lst" "$RULES_DIR/evdev.extras.lst" "$RULES_DIR/base.extras.lst"

echo ""
echo "Installation complete!"
echo "To activate in GNOME Settings:"
echo "  1. Open GNOME Settings -> Keyboard -> Input Sources."
echo "  2. Search and add 'English (US-Czech hybrid)'."
