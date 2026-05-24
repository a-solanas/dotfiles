#!/bin/bash
# Terminal environment setup
# Installs: GNU Stow, Fish, modern CLI tools, Starship, JetBrains Mono Nerd Font, LazyVim

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

install_terminal_tools() {
    print_step "Installing Terminal Tools"

    if ! command_exists brew; then
        handle_error "Homebrew is not installed. Run scripts/brew/01-manager.sh first."
    fi

    local packages=(
        "bat"           # Better cat with syntax highlighting
        "btop"          # Modern resource monitor
        "eza"           # Modern ls replacement
        "fastfetch"     # System information tool
        "fd"            # Better find
        "fish"          # User-friendly shell
        "fzf"           # Fuzzy finder
        "gh"            # GitHub CLI
        "glow"          # Markdown renderer for terminal
        "jq"            # JSON processor
        "lazydocker"    # Terminal UI for docker
        "lazygit"       # Terminal UI for git
        "neovim"        # Modern vim
        "ripgrep"       # Ultra-fast grep alternative
        "starship"      # Cross-shell prompt
        "stow"          # GNU Stow for symlink management
        "tlrc"          # Simplified man pages
        "zoxide"        # Smarter cd command
    )

    for package in "${packages[@]}"; do
        if brew list "$package" &>/dev/null; then
            print_info "$package is already installed"
        else
            print_info "Installing $package..."
            if brew install "$package" 2>/dev/null; then
                print_success "Installed $package"
            else
                print_warning "Could not install $package (may not be available)"
            fi
        fi
    done

    print_info "Installing JetBrains Mono Nerd Font..."
    if brew list --cask font-jetbrains-mono-nerd-font &>/dev/null; then
        print_info "JetBrains Mono Nerd Font is already installed"
    else
        if brew install --cask font-jetbrains-mono-nerd-font 2>/dev/null; then
            print_success "Installed JetBrains Mono Nerd Font"
        else
            print_warning "Could not install JetBrains Mono Nerd Font"
        fi
    fi
}

install_lazyvim() {
    print_step "Installing LazyVim (Neovim configuration)"

    if [ -d "$HOME/.config/nvim" ]; then
        print_info "Neovim config already exists at ~/.config/nvim"
        if ! ask_confirmation "Backup existing config and install LazyVim?"; then
            print_info "Skipping LazyVim installation"
            return 0
        fi

        local ts
        ts=$(date +%Y%m%d_%H%M%S)
        mv "$HOME/.config/nvim"           "$HOME/.config/nvim.backup.$ts"
        [ -d "$HOME/.local/share/nvim" ] && mv "$HOME/.local/share/nvim"  "$HOME/.local/share/nvim.backup.$ts"
        [ -d "$HOME/.local/state/nvim" ] && mv "$HOME/.local/state/nvim"  "$HOME/.local/state/nvim.backup.$ts"
        [ -d "$HOME/.cache/nvim" ]       && mv "$HOME/.cache/nvim"        "$HOME/.cache/nvim.backup.$ts"
    fi

    print_info "Cloning LazyVim starter..."
    git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
    rm -rf "$HOME/.config/nvim/.git"
    print_success "LazyVim installed — run: nvim"
}

verify_terminal_tools() {
    print_step "Verifying Terminal Tools"

    local tools=(
        "bat:bat"           "btop:btop"         "eza:eza"
        "fastfetch:fastfetch" "fd:fd"            "fish:fish"
        "fzf:fzf"           "gh:gh"             "glow:glow"
        "jq:jq"             "lazydocker:lazydocker" "lazygit:lazygit"
        "nvim:neovim"       "rg:ripgrep"        "starship:starship"
        "stow:stow"         "tldr:tlrc"         "zoxide:zoxide"
    )

    local ok=0 fail=0
    for entry in "${tools[@]}"; do
        IFS=':' read -r cmd name <<< "$entry"
        if command_exists "$cmd"; then
            print_success "$name"; (( ok++ ))
        else
            print_warning "$name not found"; (( fail++ ))
        fi
    done

    echo ""
    [ $fail -eq 0 ] \
        && print_success "All $ok tools verified" \
        || print_warning "$ok ok, $fail missing"
}

main() {
    install_terminal_tools

    if ask_confirmation "Install LazyVim (Neovim configuration)?"; then
        install_lazyvim
    fi

    verify_terminal_tools
    print_success "Terminal environment setup complete!"
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
