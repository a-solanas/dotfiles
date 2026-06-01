#!/bin/bash
# Install GUI applications via Homebrew Casks
# Applications: Firefox, Obsidian, VSCodium, WezTerm, Rectangle, Alt-Tab, WhatsApp, Deskflow, Burp Suite

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

install_applications() {
    print_step "Installing GUI Applications"
    
    if ! command_exists brew; then
        handle_error "Homebrew is not installed. Run scripts/manager.sh first."
    fi

    # Ensure casks are installed to ~/Applications (no sudo required)
    # Falls back to whatever is already set in the environment
    export HOMEBREW_CASK_OPTS="${HOMEBREW_CASK_OPTS:---appdir=$HOME/Applications}"
    print_info "Installing casks to: $(echo "$HOMEBREW_CASK_OPTS" | sed 's/--appdir=//')"
    
    # Tap custom repositories
    print_info "Adding custom taps..."
    if ! brew tap | grep -q "deskflow/tap"; then
        print_info "Tapping deskflow/tap..."
        brew tap deskflow/tap
        print_success "Added deskflow/tap"
    else
        print_info "deskflow/tap already tapped"
    fi
    
    local casks=(
        "alt-tab"                      # Better window switcher
        "burp-suite-professional"      # Security testing tool
        "deskflow"                     # Mouse/keyboard sharing (formerly Synergy)
        "finetune"                     # Menu bar calendar
        "firefox"                      # Web browser
        "jordanbaird-ice"              # Menu bar manager
        "lm-studio"                    # LLM Studio - Local LLM runner
        "maccy"                        # Clipboard manager
        "obsidian"                     # Note-taking app
        "rectangle"                    # Window management
        "utm"                          # Virtual machines
        "vscodium"                     # Code editor (open-source VS Code)
        "wezterm"                      # Terminal emulator
        "whatsapp"                     # Messaging app
    )
    
    print_info "Installing applications: ${casks[*]}"
    
    for cask in "${casks[@]}"; do
        if brew list --cask "$cask" &>/dev/null; then
            print_info "$cask is already installed"
        else
            print_info "Installing $cask..."
            if brew install --cask "$cask" 2>/dev/null; then
                print_success "Installed $cask"
                
                # Special warnings for specific apps
                if [[ "$cask" == "jordanbaird-ice" ]]; then
                    print_warning "Ice requires admin/superuser rights to manage menu bar items"
                    print_info "Grant accessibility permissions when prompted after launching Ice"
                fi
            else
                print_warning "Could not install $cask (may not be available or requires manual install)"
            fi
        fi
    done
}

verify_applications() {
    print_step "Verifying Application Installations"

    # Checks ~/Applications first, then /Applications
    local apps=(
        "Finetune.app:Finetune"
        "Firefox.app:Firefox"
        "Obsidian.app:Obsidian"
        "VSCodium.app:VSCodium"
        "Rectangle.app:Rectangle"
        "AltTab.app:AltTab"
        "WhatsApp.app:WhatsApp"
        "Deskflow.app:Deskflow"
        "WezTerm.app:WezTerm"
        "Ice.app:Ice (menu bar)"
        "Maccy.app:Maccy"
        "LM Studio.app:LM Studio"
        "UTM.app:UTM"
    )
    
    echo ""
    local verified=0
    local failed=0
    
    for app_info in "${apps[@]}"; do
        IFS=':' read -r app_bundle app_name <<< "$app_info"
        if [ -d "$HOME/Applications/$app_bundle" ] || [ -d "/Applications/$app_bundle" ]; then
            print_success "$app_name is installed"
            verified=$((verified + 1))
        else
            print_info "$app_name is not installed"
            failed=$((failed + 1))
        fi
    done
    
    echo ""
    if [ $failed -eq 0 ]; then
        print_success "All applications verified! ($verified apps)"
    else
        print_info "Verified $verified apps, $failed apps not installed"
    fi
}

main() {
    install_applications
    verify_applications
    
    print_success "GUI applications installation complete!"
    print_info "Some applications may require additional setup or permissions"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
