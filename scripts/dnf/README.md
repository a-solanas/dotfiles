# scripts/dnf/

Bootstrap scripts for **Fedora**.

## Status

**Planned** — not yet implemented. Scripts will be added when this distro is actively used.

## Package manager

Uses `dnf` for all package installation. Some tools are installed via COPR repos or
upstream installers when not available in the default Fedora repos.

## Script layout

```
dnf/
├── README.md
└── [0-9][0-9]-*.sh     ← numbered scripts, run in order by setup.sh
```
