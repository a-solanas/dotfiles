# Shell Aliases & Abbreviations

## Modern CLI Tools
```bash
find     → fd           # Fast find
grep     → rg           # Ripgrep
ls       → eza          # Modern ls
ll       → eza -la      # Long listing
tree     → eza --tree   # Tree view
ff       → fastfetch    # System info
cd       → z            # Zoxide (smarter cd)
```

## Configuration
```bash
fishconfig    # Open fish config in VS Code
zshconfig     # Open zsh config in VS Code
reload        # Reload fish config
```

## Fish Keybindings
- `CTRL + L` - Clear screen (without erasing scrollback)
- `CTRL + R` - Search history with fzf
- `CTRL + T` - Find files with fzf
- `ALT + C` - Change directory with fzf
- `ALT + Space` - Expand abbreviation (without executing)

## Git
```bash
lazygit           # Terminal UI for git
git status        # Check status
lzd               # Terminal UI for docker (lazydocker)
git add -A        # Stage all changes
git commit -m ""  # Commit with message
git push          # Push to remote
git pull          # Pull from remote
```

## Utilities
```bash
cheat             # View full cheatsheet
cheat wez         # View only wezterm section
cheat dev         # View only dev-tools section
btop              # Resource monitor
fastfetch         # System info
```

## Dotfiles Management
```bash
cd ~/.dotfiles         # Go to dotfiles
cd ~/.dotfiles/stow    # Go to stow packages
stow -t $HOME zsh            # Stow zsh config
stow -t $HOME -R fish        # Restow fish config
stow -t $HOME -D wezterm     # Unstow wezterm config
```
---
