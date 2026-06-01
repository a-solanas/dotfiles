# TODO

## Backlog

### scripts/pacman/ — PRIORITY (current machine: CachyOS)

Suggested script split — see `scripts/pacman/README.md` for detail:

- [ ] `01-update.sh` — full system update, install paru
- [ ] `02-terminal.sh` — core tool stack (fish, neovim, wezterm, starship, bat, eza, fd…)
- [ ] `03-apps.sh` — desktop apps (discord, chromium, vscodium, firefox)
- [ ] `04-flatpak.sh` — flatpak setup + Synology Drive
- [ ] `05-gaming.sh` — gaming packages via CachyOS repo, umu-launcher
- [ ] `06-extras.sh` — ollama, opencode, other curl-installed tools
- [x] `07-stow.sh` — symlink dotfiles with GNU Stow

### Stow packages

- [x] `stow/fish/` — config.fish, functions, abbreviations
- [x] `stow/wezterm/` — wezterm.lua
- [ ] `stow/neovim/` — LazyVim config
- [x] `stow/starship/` — starship.toml
- [ ] `stow/btop/` — btop.conf
- [ ] `stow/bat/` — config
- [ ] `stow/fastfetch/` — config.jsonc
- [ ] `stow/lazygit/` — config.yml
- [ ] `stow/lazydocker/` — config.yml
- [ ] `stow/vscodium/` — settings.json, keybindings.json

### Docs

- [ ] Update `docs/cheatsheet/` for Linux (currently macOS-focused, copied from work dotfiles)
- [ ] Write `docs/setup-guide.md` for this repo
- [x] Move `previous.md` to `docs/previous.md` (loose file at root)

### Review

- [ ] `scripts/utils/logging.sh` — verify `print_banner` centering renders correctly across terminals (box drawing chars may vary by font)

### Future

- [ ] `scripts/apt/` — implement when actively using Debian / Mint
- [ ] `scripts/dnf/` — implement when actively using Fedora
- [ ] `scripts/pwner/kali/` — implement kali tweaks subtree
- [ ] `stow/git/` — global `.gitconfig` with `[includeIf]` identity switching
- [ ] Skill: surface fish function substitutions to Claude at session start
- [ ] `scripts/brew/` — validation pass once using a personal Mac again
