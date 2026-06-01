# scripts/pacman/

Bootstrap scripts for **Arch-based distros** — primary target is CachyOS.
Uses `pacman` as the base package manager; `paru` for AUR packages.

## Status

**Active** — this is the current daily-driver distro. Scripts are built and tested here first.

## CachyOS reference

The [CachyOS Wiki](https://wiki.cachyos.org/) is the authoritative reference for this target.
Key sections:

- [Gaming setup](https://wiki.cachyos.org/configuration/gaming/) — `umu-launcher`, proton, gamemode
- [General configuration](https://wiki.cachyos.org/configuration/) — DNS, system tweaks, kernel options

## Things done manually (to be scripted)

Tracked from initial setup — candidates for the numbered scripts below:

- System update: `sudo pacman -Syu`
- Gaming: `sudo pacman -S cachyos/umu-launcher` (see wiki link above)
- Desktop apps: `discord`, `chromium`, `vscodium` via pacman
- Flatpak: Synology Drive
- Terminal tools: `ollama` and `opencode` via their curl installers
- DNS change (distro-level)
- UI tweaks: panel height → 42, font sizes → 11/9
- Audio: disable ALSA auto-mute so line out and headphones work simultaneously — `amixer -c 0 set 'Auto-Mute Mode' 'Disabled' && sudo alsactl store`

## Script layout

```
pacman/
├── README.md           ← you are here
└── [0-9][0-9]-*.sh     ← numbered scripts, run in order by setup.sh
```

Suggested script split when building this out:

| Script | Purpose |
|---|---|
| `01-update.sh` | Full system update, install paru |
| `02-terminal.sh` | Core tool stack (fish, neovim, wezterm, starship…) |
| `03-apps.sh` | Desktop apps (discord, chromium, vscodium, firefox…) |
| `04-flatpak.sh` | Flatpak setup + apps (Synology Drive…) |
| `05-gaming.sh` | Gaming packages via CachyOS repo + umu-launcher |
| `06-extras.sh` | Ollama, opencode, other curl-installed tools |
| `07-stow.sh` | Symlink dotfiles with GNU Stow |
