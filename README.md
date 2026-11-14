# US-Czech Hybrid Keyboard Layout

A custom XKB keyboard layout combining US QWERTY with Czech diacritics. It greatly improves the typing experience when you need to switch from English to Czech.

The learning curve is extremely fast - especially if you have a numpad or don't type number often. See the layout below.

## Layout

Base layout is US QWERTY. The number row is modified as follows:

| Key | Default | Shift | AltGr |
|-----|---------|-------|-------|
| `   | `       | ~     |   	|
| 1   | ˇ (dead)| !     | 1     |
| 2   | ě       | @     | 2     |
| 3   | š       | #     | 3     |
| 4   | č       | $     | 4     |
| 5   | ř       | %     | 5     |
| 6   | ž       | ^     | 6     |
| 7   | ý       | &     | 7     |
| 8   | á       | *     | 8     |
| 9   | í       | (     | 9     |
| 0   | ´ (dead)| )     | 0     |
| ;   | ;       | :     | ů     |

Note that both Left Alt and Right Alt (AltGr) select level 3.

### Dead Keys

- **ˇ (caron/háček)**: Press ˇ then a letter to compose: ď, ť, ň (and ě, š, č, ř, ž which are also direct)
- **´ (acute)**: Press ´ then a letter to compose: é, ú, ó (and á, ý, í which are also direct)
- **ů**: Press AltGr+; to type ů

## Installation

For Fedora 45 / GNOME on Wayland. Requires libxkbcommon 1.13+ and
xkeyboard-config 2.45+; DNF checks these when installing the RPM.

Build and install from the repository directory:

```bash
sudo dnf install rpm-build
rpmbuild -bb --define "_topdir $PWD/build" --define "_sourcedir $PWD" us-czech-hybrid.spec
sudo dnf install ./build/RPMS/noarch/us-czech-hybrid-*.rpm
```

The package installs only its own files under
`/usr/share/xkeyboard-config.d/us-czech-hybrid/`, using the standard
[XKB extension packaging mechanism](https://xkbcommon.org/doc/current/packaging-keyboard-layouts.html).
It does not edit Fedora's keyboard database. Fish is not required.

### After Installation

1. Log out and back in, then open GNOME Settings → Keyboard → Input Sources
2. Click "+" and search for "Czech hybrid" or "enCZ"
3. Add "English (US-Czech hybrid)"

## License

MIT
