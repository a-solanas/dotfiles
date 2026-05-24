#!/bin/bash
# Global configuration — sourced by all install scripts via utils.sh
# Override any value by setting the variable in your environment before running setup.sh

# Repo
export DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/a-solanas/dotfiles.git}"

# Root of the repo — auto-detected from this file's location
_cfg_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export DOTFILES_DIR="${DOTFILES_DIR:-$_cfg_dir}"
unset _cfg_dir

# Runtime
export BACKUP_BASE_DIR="${BACKUP_BASE_DIR:-$HOME/.bak}"
export DOTFILES_LOG_FILE="${DOTFILES_LOG_FILE:-$HOME/.dotfiles_setup.log}"
export DEBUG="${DEBUG:-0}"

# Git identity (leave empty to be prompted interactively)
export GIT_USER_NAME="${GIT_USER_NAME:-}"
export GIT_USER_EMAIL="${GIT_USER_EMAIL:-}"

# Stow — universal packages stowed on every OS
# OS-specific packages (e.g. apps) are declared in each distro's stow script
export STOW_UNIVERSAL_PACKAGES=(bat btop fastfetch fish lazydocker lazygit neovim starship vscodium wezterm)
