# Dotfiles

Personal dotfiles for macOS and Linux, managed with GNU Stow. Kept permanently separate from work dotfiles.

## Core tool stack

Tools installed on every machine regardless of distro. These form the baseline for all Stow packages.

| Tool | Purpose |
|---|---|
| fish | Primary shell |
| bash | Scripting only |
| wezterm | Terminal emulator |
| vscodium | Primary editor |
| neovim | Terminal editor (LazyVim distribution) |
| starship | Cross-shell prompt |
| bat | Enhanced `cat` |
| btop | Resource monitor |
| eza | Enhanced `ls` |
| fastfetch | System info |
| fd | Enhanced `find` |
| fzf | Fuzzy finder |
| glow | Terminal markdown renderer |
| jq | JSON processor |
| lazydocker | Docker TUI |
| lazygit | Git TUI |
| ripgrep | Enhanced `grep` |
| stow | Symlink manager |
| gh | GitHub CLI |
| tlrc | Simplified man pages |
| zoxide | Smarter `cd` |

**Stow packages — universal** (stowed on all OSes): fish, wezterm, neovim, starship, btop, bat, fastfetch, lazygit, lazydocker, vscodium. Tools without meaningful config (eza, fd, fzf, glow, jq, ripgrep, tlrc, zoxide, stow, gh) are installed but not stowed.

**Stow packages — OS-specific** (stowed only on the relevant OS): apps (XDG `.desktop` entries and icons — Linux only; skipped by macOS stow script). Each distro's `07-stow.sh` controls which categories it stows.

> **Future task**: add a `git` Stow package with a global `.gitconfig`. Key feature: `[includeIf]` to auto-select identity by directory. Deferred — personal and work machines are kept fully separate, so identity switching is not currently needed.

**Enhanced tools** (`bat`, `eza`, `fd`, `ripgrep`): never aliased over the standard commands (`cat`, `ls`, `find`, `grep`). Keeps scripts, shell prompts, and AI tool calls predictable.

> **Future consideration**: if fish functions start shadowing standard commands, a Claude Code skill that surfaces those substitutions at session start would prevent Claude from running commands with mismatched syntax. Fish abbreviations are safe (interactive-only); fish functions are not.

## Pwner

The `scripts/pwner/` subtree bootstraps offensive security environments. It is independent of the main Bootstrap flow and is never run on a daily-driver machine. Always triggered manually via `./setup.sh --pwner`.

| Concept | Meaning |
|---|---|
| Module | An optional install script under `pwner/modules/` that adds a category of security tools (recon, web, crack). Sourced interactively during pwner setup. |
| SecLists | The [danielmiessler/SecLists](https://github.com/danielmiessler/SecLists) wordlist collection, installed to `/opt/seclists`. |
| fix-dns | A pre-setup script that corrects DNS resolution in fresh Debian VMs before any package installation. Must run before `pwner/setup.sh`. |

## Language

**Package**:
A Stow-managed unit — a directory under `stow/` that mirrors the target file structure relative to `$HOME`. Symlinking a package means running `stow -t $HOME <package>`.
_Avoid_: module, config, bundle

**Bootstrap**:
The full one-shot setup process for a new machine — runs `setup.sh`, which detects the OS and executes numbered scripts in order.
_Avoid_: install, setup, provisioning

**Dotfile**:
Any config file managed by this repo (whether symlinked via Stow or installed by a script). Not just hidden files.
_Avoid_: config file (too generic)

## Relationships

- A **Package** contains one or more **Dotfiles**
- **Bootstrap** symlinks all relevant **Packages** for the current OS

## Structure

```
/
├── setup.sh                    ← entry point: auto-detects distro, --help, --pwner
├── scripts/
│   ├── config.sh               ← global config (DOTFILES_DIR, LOG_FILE, REPO, git vars)
│   ├── utils.sh                ← loader: sources config.sh + utils/* + distro config.sh
│   ├── utils/
│   │   ├── colors.sh           ← color vars
│   │   ├── logging.sh          ← print_banner (auto-size), print_*, log_to_file
│   │   ├── system.sh           ← get_arch, get_os, get_distro_id
│   │   └── helpers.sh          ← command_exists, ask_confirmation, git config
│   ├── pacman/                 ← Arch / CachyOS — ACTIVE, primary distro
│   ├── apt/                    ← Debian / Mint / Ubuntu — planned
│   ├── dnf/                    ← Fedora — planned
│   ├── brew/                   ← macOS (Homebrew) — dormant reference
│   │   ├── config.sh           ← macOS-only vars (keyboard IDs, dock prefs)
│   │   └── utils-macos.sh      ← is_macos, is_arm64 helpers
│   └── pwner/                  ← offensive security (manual: ./setup.sh --pwner)
│       ├── setup.sh            ← Debian offensive build (arch-aware)
│       ├── fix-dns.sh          ← DNS fix for fresh VMs
│       └── modules/            ← recon, web, crack
└── stow/
    └── <package>/              ← one Package per tool/app, shared across all distros
```

## setup.sh flags

| Flag | Behaviour |
|---|---|
| *(none)* | Auto-detect distro via `/etc/os-release`, run numbered scripts |
| `--help` | Print usage, distro targets, and examples |
| `--pwner` | Run offensive security setup; auto-detects Kali vs Debian |

Kali (`ID=kali`) is **never** run through the normal flow — `./setup.sh` on Kali errors and redirects to `--pwner`.

## Decisions

- **`setup.sh` as the single entry point** — detects the distro via `/etc/os-release` (`ID` and `ID_LIKE` fields) and delegates to the appropriate scripts subtree. macOS detected via `uname`. Modern distros only — no legacy fallbacks needed.
- **Scripts organised by package manager, not distro name** — `pacman/`, `apt/`, `dnf/`. A distro is just a package-manager ecosystem from the install script's perspective. Grown gradually as each distro is actually used.
- **`pwner/` lives under `scripts/`** — offensive security is a distinct use-case, not a distro variant. Triggered via `--pwner` only; Kali auto-detected within that flow.
- **`scripts/config.sh` is the single source of truth** — all global vars (`DOTFILES_DIR`, `DOTFILES_LOG_FILE`, `BACKUP_BASE_DIR`, git identity) live here. Distro-specific configs (e.g. `brew/config.sh`) only add their own vars on top.
- **`utils/` folder for shared code** — `scripts/utils.sh` is a thin loader. Actual code lives in `utils/colors.sh`, `utils/logging.sh`, `utils/system.sh`, `utils/helpers.sh`. Add new shared utilities by dropping a file in `utils/`.
- **`print_banner` for all banners** — parametrised, auto-centers, falls back to plain print if text exceeds box width. Each distro script calls `print_banner "<Title>"` for consistent output.
- **Binary downloads are arch-aware** — scripts detect `amd64` vs `arm64` via `uname -m` at runtime. No hardcoded architecture assumptions.
- **macOS is in scope but dormant** — `scripts/brew/` exists as a reference, seeded from work dotfiles. Not actively maintained until a personal Mac is in use.
- **Stow packages are distro-agnostic** — config files are shared across all distros. OS-specific divergence lives only in the install scripts.
- **Permanently separate from work dotfiles** — work dotfiles covers the work laptop only. Personal repo covers personal machines. Work dotfiles serves as a reference/starting point, not a merge target.
