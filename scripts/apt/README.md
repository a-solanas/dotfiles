# scripts/apt/

Bootstrap scripts for **Debian-based distros** — covers Debian, Ubuntu, Linux Mint.

## Status

**Planned** — not yet implemented. Scripts will be added when this distro is actively used.

## Package manager

Uses `apt` for all package installation. Some tools not in the Debian repos are installed
via their upstream installers (curl) or third-party apt sources.

Notable differences from pacman:
- Some packages have different names (e.g. `batcat` instead of `bat`, `fdfind` instead of `fd`)
- Modern CLI tools often lag behind upstream — may need GitHub release installs
- No AUR equivalent; use upstream install scripts or add extra apt sources

## Script layout

```
apt/
├── README.md
└── [0-9][0-9]-*.sh     ← numbered scripts, run in order by setup.sh
```
