#!/bin/bash
# Install Homebrew package manager
# This is the first script to run as everything else depends on Homebrew

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
source "$SCRIPT_DIR/utils-macos.sh"

install_homebrew() {
    print_step "Installing Homebrew Package Manager"
    
    # Step 1: Check if brew command works
    if command_exists brew; then
        print_success "Homebrew is already installed and in PATH"
        
        # Update Homebrew
        print_info "Updating Homebrew..."
        brew update
        print_success "Homebrew updated"
        return 0
    fi
    
    # Step 2: Check if brew binary exists at expected paths
    local brew_path
    if is_arm64; then
        brew_path="/opt/homebrew/bin/brew"
    else
        brew_path="/usr/local/bin/brew"
    fi
    
    if [ -x "$brew_path" ]; then
        # Step 3: Binary exists but not in PATH - add it
        print_info "Homebrew found at $brew_path but not in PATH"
        print_info "Adding Homebrew to PATH..."
        
        # Add to zprofile for zsh
        if ! grep -q "$brew_path shellenv" ~/.zprofile 2>/dev/null; then
            echo "" >> ~/.zprofile
            echo "# Homebrew" >> ~/.zprofile
            echo "eval \"\$($brew_path shellenv)\"" >> ~/.zprofile
            print_success "Added Homebrew to ~/.zprofile"
        fi
        
        # Source for current session
        eval "$($brew_path shellenv)"
        
        if command_exists brew; then
            print_success "Homebrew is now available"
            brew update
            print_success "Homebrew updated"
        else
            handle_error "Failed to add Homebrew to PATH"
        fi
        return 0
    fi
    
    # Step 4: Install Homebrew
    print_info "Homebrew not found. Installing..."
    
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH after installation
    if is_arm64; then
        brew_path="/opt/homebrew/bin/brew"
    else
        brew_path="/usr/local/bin/brew"
    fi
    
    if [ -x "$brew_path" ]; then
        print_info "Adding Homebrew to PATH..."
        if ! grep -q "$brew_path shellenv" ~/.zprofile 2>/dev/null; then
            echo "" >> ~/.zprofile
            echo "# Homebrew" >> ~/.zprofile
            echo "eval \"\$($brew_path shellenv)\"" >> ~/.zprofile
        fi
        eval "$($brew_path shellenv)"
        
        if command_exists brew; then
            print_success "Homebrew installed successfully"
        else
            handle_error "Homebrew installation failed - command not available"
        fi
    else
        handle_error "Homebrew installation failed - binary not found at $brew_path"
    fi
}

setup_user_applications_dir() {
    print_step "Setting Up User Applications Directory"

    local user_apps_dir="$HOME/Applications"

    # Create ~/Applications if it doesn't exist
    if [ ! -d "$user_apps_dir" ]; then
        print_info "Creating ~/Applications directory..."
        mkdir -p "$user_apps_dir"
        print_success "Created ~/Applications"
    else
        print_info "~/Applications already exists"
    fi

    # Export for current session
    export HOMEBREW_CASK_OPTS="--appdir=$user_apps_dir"

    # Persist in ~/.zprofile (zsh)
    if ! grep -q 'HOMEBREW_CASK_OPTS' ~/.zprofile 2>/dev/null; then
        echo "" >> ~/.zprofile
        echo "# Homebrew casks: install to user Applications (no sudo required)" >> ~/.zprofile
        echo 'export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"' >> ~/.zprofile
        print_success "Persisted HOMEBREW_CASK_OPTS in ~/.zprofile"
    else
        print_info "HOMEBREW_CASK_OPTS already configured in ~/.zprofile"
    fi

    print_success "Cask applications will be installed to ~/Applications"
}

main() {
    install_homebrew
    setup_user_applications_dir
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
