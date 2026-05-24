#!/bin/bash
# Run GNU Stow to symlink all dotfiles
# Creates symlinks from home directory to dotfiles repo

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# DOTFILES_DIR and BACKUP_BASE_DIR are auto-detected via config.sh
BACKUP_DIR="$BACKUP_BASE_DIR/dotfiles_$(date +%Y%m%d_%H%M%S)"

check_and_handle_conflicts() {
    print_step "Checking for Existing Configurations"
    
    local conflicts_found=0
    local files_to_check=(
        "$HOME/.config/fish"
        "$HOME/.config/starship.toml"
        "$HOME/.config/wezterm"
        "$HOME/.config/nvim"
        "$HOME/.config/fastfetch"
        "$HOME/.config/btop"
        "$HOME/.config/VSCodium/User/settings.json"
        "$HOME/.config/lazygit"
        "$HOME/.config/lazydocker"
    )
    
    # Check for conflicts (real files/dirs) or dangling symlinks
    for file in "${files_to_check[@]}"; do
        if [ -L "$file" ] && [ ! -e "$file" ]; then
            print_warning "Dangling symlink found: $file"
            conflicts_found=$((conflicts_found + 1))
        elif [ -e "$file" ] && [ ! -L "$file" ]; then
            print_warning "Existing config found: $file"
            conflicts_found=$((conflicts_found + 1))
        fi
    done
    
    # If conflicts found, ask user what to do
    if [ $conflicts_found -gt 0 ]; then
        echo ""
        print_warning "Found $conflicts_found existing configuration file(s) that will conflict with stow."
        print_info "These files need to be backed up and removed before creating symlinks."
        echo ""
        
        if ! ask_confirmation "Backup and remove existing files to continue?"; then
            print_warning "Stow setup cancelled by user."
            exit 0
        fi
        
        # Backup and remove conflicts
        print_step "Backing Up and Removing Conflicting Files"
        mkdir -p "$BACKUP_DIR"
        
        for file in "${files_to_check[@]}"; do
            if [ -L "$file" ] && [ ! -e "$file" ]; then
                # Dangling symlink - just remove it, nothing to back up
                rm "$file"
                print_success "Removed dangling symlink: $file"
            elif [ -e "$file" ] && [ ! -L "$file" ]; then
                # Backup
                if cp -r "$file" "$BACKUP_DIR/" 2>/dev/null; then
                    print_info "Backed up: $file"
                else
                    print_warning "Could not backup: $file (continuing anyway)"
                fi
                
                # Remove
                rm -rf "$file"
                print_success "Removed: $file"
            fi
        done
        
        print_success "Backed up $conflicts_found file(s) to: $BACKUP_DIR"
    else
        print_success "No conflicting files found!"
    fi
}

stow_pass() {
    local label="$1"; shift
    local packages=("$@")

    [ ${#packages[@]} -eq 0 ] && return

    print_step "$label"

    cd "$DOTFILES_DIR/stow"

    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            print_warning "Package '$pkg' not found in stow/ — skipping"
            continue
        fi

        print_info "Stowing $pkg..."

        if stow -t "$HOME" "$pkg" 2>/dev/null; then
            print_success "Stowed $pkg"
        else
            print_error "Failed to stow $pkg — there may still be conflicts"
        fi
    done
}

stow_packages() {
    if ! command_exists stow; then
        handle_error "GNU Stow is not installed. Run 02-terminal.sh first."
    fi

    # macOS has no OS-specific stow packages yet
    local os_packages=()

    # Step 1 — universal (same on every OS)
    stow_pass "Universal Packages" "${STOW_UNIVERSAL_PACKAGES[@]}"

    # Step 2 — OS-specific (empty on macOS for now)
    stow_pass "OS-Specific Packages" "${os_packages[@]}"
}

verify_symlinks() {
    print_step "Verifying Symlinks"
    
    local configs=(
        "$HOME/.config/fish:fish config"
        "$HOME/.config/starship.toml:starship config"
        "$HOME/.config/wezterm:wezterm config"
        "$HOME/.config/nvim:neovim config"
        "$HOME/.config/fastfetch:fastfetch config"
        "$HOME/.config/btop:btop config"
        "$HOME/.config/VSCodium/User/settings.json:vscodium settings"
        "$HOME/.config/lazygit:lazygit config"
        "$HOME/.config/lazydocker:lazydocker config"
    )
    
    local verified=0
    local failed=0
    
    for config_entry in "${configs[@]}"; do
        IFS=':' read -r config_path config_name <<< "$config_entry"
        
        if [ -L "$config_path" ]; then
            print_success "$config_name is symlinked ✓"
            verified=$((verified + 1))
        elif [ -e "$config_path" ]; then
            print_warning "$config_name exists but is NOT a symlink"
            failed=$((failed + 1))
        fi
    done
    
    echo ""
    if [ $failed -eq 0 ]; then
        print_success "All symlinks verified successfully! ($verified symlinks)"
    else
        print_warning "Verified $verified symlinks, but $failed configs are not symlinked"
    fi
}

main() {
    check_and_handle_conflicts
    stow_packages
    verify_symlinks
    
    echo ""
    print_success "GNU Stow setup complete!"
    
    if [ -d "$BACKUP_DIR" ]; then
        print_info "Backups saved to: $BACKUP_DIR"
    fi
    
    echo ""
    print_info "Restart your shell or run 'exec fish' to apply changes"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
