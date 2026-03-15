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

### Dead Keys

- **ˇ (caron/háček)**: Press ˇ then a letter to compose: ď, ť, ň (and ě, š, č, ř, ž which are also direct)
- **´ (acute)**: Press ´ then a letter to compose: é, ú, ó (and á, ý, í which are also direct)
- **ů**: Press AltGr+; to type ů

## Installation

```bash
sudo ./install.sh
```

### After Installation

1. Log out and log back in (or restart)
2. Open GNOME Settings → Keyboard → Input Sources
3. Click "+" and search for "Czech hybrid" or "enCZ"
4. Add "English (US-Czech hybrid)"

## Uninstallation

```bash
sudo ./uninstall.sh
```

## License

MIT
