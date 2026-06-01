# scripts/brew/

Bootstrap scripts for **macOS** via Homebrew.

## Status

**Dormant** — kept as a reference and for quick ramp-up when moving to a new personal Mac
or changing jobs. Seeded from work dotfiles; updated when actively used.

## Package manager

Uses [Homebrew](https://brew.sh/) for CLI tools (`brew install`) and GUI apps (`brew install --cask`).
Casks are installed to `~/Applications` (no sudo required).

## Script layout

```
brew/
├── README.md
├── config.sh           ← macOS-specific config (keyboard, dock prefs)
├── utils-macos.sh      ← is_macos / is_arm64 helpers
└── [0-9][0-9]-*.sh     ← numbered scripts, run in order by setup.sh
```

| Script | Purpose |
|---|---|
| `01-manager.sh` | Install / update Homebrew, set up `~/Applications` |
| `02-terminal.sh` | Core tool stack + LazyVim |
| `03-apps.sh` | GUI apps (Firefox, VSCodium, WezTerm, Rectangle…) |
| `04-macos.sh` | macOS system preferences (Finder, Dock, keyboard layouts) |
| `05-dev-tools.sh` | Dev tools (Podman, kubectl, gh, pyenv, uv…) |
| `06-stow.sh` | Symlink dotfiles with GNU Stow |
