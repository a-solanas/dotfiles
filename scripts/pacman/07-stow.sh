#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# OS-specific packages for Linux / pacman systems
STOW_OS_PACKAGES=(apps)

BACKUP_DIR="$BACKUP_BASE_DIR/dotfiles_$(date +%Y%m%d_%H%M%S)"

stow_pass() {
    local label="$1"; shift
    local packages=("$@")

    print_step "$label"

    cd "$DOTFILES_DIR/stow"

    for pkg in "${packages[@]}"; do
        if [ ! -d "$pkg" ]; then
            print_warning "Package '$pkg' not found in stow/ — skipping"
            continue
        fi

        # Simulate first to detect conflicts
        local conflicts
        conflicts=$(stow -n -t "$HOME" "$pkg" 2>&1 | grep "existing target" || true)

        if [ -n "$conflicts" ]; then
            print_warning "Conflicts detected for $pkg:"
            echo "$conflicts"

            mkdir -p "$BACKUP_DIR"

            while IFS= read -r line; do
                local target
                target=$(echo "$line" | grep -oP "(?<=existing target is not owned by stow: ).*" || \
                         echo "$line" | grep -oP "(?<=existing target is not a symlink: ).*" || true)
                [ -z "$target" ] && continue
                local full="$HOME/$target"
                if [ -e "$full" ] || [ -L "$full" ]; then
                    cp -r "$full" "$BACKUP_DIR/" 2>/dev/null && print_info "Backed up: $full"
                    rm -rf "$full"
                fi
            done <<< "$conflicts"
        fi

        if stow -t "$HOME" "$pkg"; then
            print_success "Stowed $pkg"
        else
            print_error "Failed to stow $pkg"
        fi
    done
}

verify_symlinks() {
    print_step "Verifying Symlinks"

    local all_packages=("${STOW_UNIVERSAL_PACKAGES[@]}" "${STOW_OS_PACKAGES[@]}")
    local verified=0 missing=0

    cd "$DOTFILES_DIR/stow"

    for pkg in "${all_packages[@]}"; do
        [ ! -d "$pkg" ] && continue

        # Check at least one symlink from this package exists under $HOME
        local sample
        sample=$(find "$pkg" -not -type d | head -1)
        if [ -n "$sample" ]; then
            local rel="${sample#$pkg/}"
            local target="$HOME/$rel"
            if [ -L "$target" ]; then
                print_success "$pkg ✓"
                verified=$((verified + 1))
            else
                print_warning "$pkg — expected symlink missing: $target"
                missing=$((missing + 1))
            fi
        fi
    done

    echo ""
    if [ "$missing" -eq 0 ]; then
        print_success "All packages verified ($verified symlinks)"
    else
        print_warning "$verified verified, $missing with issues"
    fi
}

main() {
    print_banner "Stow Dotfiles"

    if ! command_exists stow; then
        handle_error "GNU Stow is not installed. Run 02-terminal.sh first."
    fi

    # Step 1 — universal (same on every OS)
    stow_pass "Universal Packages" "${STOW_UNIVERSAL_PACKAGES[@]}"

    # Step 2 — OS-specific (Linux / XDG)
    stow_pass "OS-Specific Packages" "${STOW_OS_PACKAGES[@]}"

    verify_symlinks

    echo ""
    print_success "Stow complete!"
    [ -d "$BACKUP_DIR" ] && print_info "Backups saved to: $BACKUP_DIR"
    echo ""
    print_info "Run 'exec fish' to apply shell changes"
}

main "$@"
