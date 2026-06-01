#!/bin/bash
# Development tools installation for work tasks
# Installs: Podman, Kubernetes tools, GitHub CLI, Node.js, Python (pyenv + uv), AWS CLI, HTTPie

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"

# ─────────────────────────────────────────────────────────────────────────────
# Package lists
# ─────────────────────────────────────────────────────────────────────────────

# Core development packages (brew install)
DEV_PACKAGES=(
    "awscli"          # AWS CLI
    "docker-compose"  # Container orchestration (works with Podman)
    "gh"              # GitHub CLI
    "helm"            # Kubernetes package manager
    "httpie"          # Modern HTTP client
    "k9s"             # Kubernetes TUI
    "kubectl"         # Kubernetes CLI
    "lazydocker"      # Docker/Podman TUI
    "node"            # Node.js and npm
    "podman"          # Container runtime (Docker alternative)
    "pyenv"           # Python version management
    "uv"              # Fast Python package/project manager
    "yq"              # YAML processor
)

# Tapped packages (tap:package format)
TAPPED_PACKAGES=(
    "int128/kubelogin:int128/kubelogin/kubelogin"  # OIDC auth for kubectl
)

# Packages to pin after install (prevent auto-upgrades)
PINNED_PACKAGES=(
    "kubelogin"
)

# ─────────────────────────────────────────────────────────────────────────────
# Generic install functions
# ─────────────────────────────────────────────────────────────────────────────

install_dev_packages() {
    print_step "Installing Development Packages"

    if ! command_exists brew; then
        handle_error "Homebrew is not installed. Run scripts/01-manager.sh first."
    fi

    for package in "${DEV_PACKAGES[@]}"; do
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
}

install_tapped_packages() {
    print_step "Installing Tapped Packages"

    for entry in "${TAPPED_PACKAGES[@]}"; do
        IFS=':' read -r tap formula <<< "$entry"
        if brew list "$formula" &>/dev/null; then
            print_info "$formula is already installed"
        else
            print_info "Tapping $tap..."
            if ! brew tap "$tap" 2>/dev/null; then
                print_warning "Could not tap $tap (may already be tapped)"
            fi
            print_info "Installing $formula..."
            if brew install "$formula" 2>/dev/null; then
                print_success "Installed $formula"
            else
                print_warning "Could not install $formula"
            fi
        fi
    done

    # Pin packages that need version stability
    for package in "${PINNED_PACKAGES[@]}"; do
        if brew list "$package" &>/dev/null; then
            if brew pin "$package" 2>/dev/null; then
                print_info "Pinned $package (prevents automatic upgrades)"
            else
                print_warning "Could not pin $package (may already be pinned)"
            fi
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Post-install: Podman (Docker compatibility)
# ─────────────────────────────────────────────────────────────────────────────

configure_podman() {
    print_step "Configuring Podman (Docker Compatibility)"

    if ! command_exists podman; then
        print_warning "Podman not found, skipping configuration"
        return 0
    fi

    # Initialize and start Podman machine if not running
    if ! podman machine list 2>/dev/null | grep -q "Currently running"; then
        print_info "Initializing Podman machine..."
        podman machine init 2>/dev/null || print_info "Podman machine already initialized"
        print_info "Starting Podman machine..."
        podman machine start
        print_success "Podman machine started"
    else
        print_success "Podman machine is already running"
    fi

    # Shell aliases are managed via stow (fish config / zshrc)
    print_info "Docker aliases (docker→podman) are managed in your shell config via stow"
}

# ─────────────────────────────────────────────────────────────────────────────
# Post-install: Rancher Desktop (optional alternative container runtime)
# ─────────────────────────────────────────────────────────────────────────────

install_rancher_desktop() {
    print_step "Installing Rancher Desktop"

    if brew list --cask rancher &>/dev/null; then
        print_info "Rancher Desktop is already installed"
    else
        print_info "Installing Rancher Desktop..."
        if brew install --cask rancher 2>/dev/null; then
            print_success "Installed Rancher Desktop"
            print_info "Launch Rancher Desktop from Applications and configure container runtime"
        else
            print_warning "Could not install Rancher Desktop"
        fi
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Post-install: pyenv (Python version management)
# ─────────────────────────────────────────────────────────────────────────────

configure_pyenv() {
    print_step "Configuring pyenv"

    if ! command_exists pyenv; then
        print_warning "pyenv not found, skipping configuration"
        return 0
    fi

    # Initialize pyenv for current session
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if ! eval "$(pyenv init -)" 2>/dev/null; then
        print_warning "Could not initialize pyenv (check installation)"
    fi

    # Shell init is managed via stow (fish: pyenv init - | source)
    print_info "pyenv shell initialization is managed in your shell config via stow"
    print_info "Installed Python versions:"
    pyenv versions
}

# ─────────────────────────────────────────────────────────────────────────────
# Post-install: uv (Python project/package management)
# ─────────────────────────────────────────────────────────────────────────────

configure_uv() {
    print_step "Configuring uv"

    if ! command_exists uv; then
        print_warning "uv not found, skipping configuration"
        return 0
    fi

    print_success "uv $(uv --version) is ready"
    print_info "uv replaces pip, venv, and poetry for project management"
    print_info "Quick start: uv init myproject && cd myproject && uv add requests"
}

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup: remove legacy Python tooling
# ─────────────────────────────────────────────────────────────────────────────

cleanup_legacy_python() {
    print_step "Cleaning Up Legacy Python Tools"

    # Remove broken Poetry installation if present
    if [ -d "$HOME/Library/Application Support/pypoetry" ]; then
        if ask_confirmation "Remove legacy Poetry installation (replaced by uv)?" "y"; then
            rm -rf "$HOME/Library/Application Support/pypoetry"
            rm -f "$HOME/.local/bin/poetry"
            print_success "Removed legacy Poetry installation"
        fi
    elif command_exists poetry; then
        print_info "Poetry found — consider removing it if you've fully switched to uv"
    else
        print_info "No legacy Python tools to clean up"
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Verification
# ─────────────────────────────────────────────────────────────────────────────

verify_installations() {
    print_step "Verifying Installations"

    local tools=(
        "podman:Podman"
        "docker-compose:Docker Compose"
        "kubectl:Kubernetes CLI"
        "k9s:K9s"
        "helm:Helm"
        "yq:yq"
        "lazydocker:lazydocker"
        "gh:GitHub CLI"
        "node:Node.js"
        "npm:npm"
        "pyenv:pyenv"
        "uv:uv"
        "python3:Python"
        "aws:AWS CLI"
        "http:HTTPie"
    )

    echo ""
    for tool_info in "${tools[@]}"; do
        IFS=':' read -r cmd name <<< "$tool_info"
        if command_exists "$cmd"; then
            print_success "$name is available"
        else
            print_warning "$name is not available"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

main() {
    print_info "This script installs development tools for work tasks."
    echo ""

    if ! ask_confirmation "Install development tools?"; then
        print_info "Skipping development tools installation"
        return 0
    fi

    # Install all packages
    install_dev_packages
    install_tapped_packages

    # Post-install configuration
    configure_podman

    if ask_confirmation "Also install Rancher Desktop as fallback container runtime?"; then
        install_rancher_desktop
    fi

    configure_pyenv
    configure_uv
    cleanup_legacy_python

    # Verify everything
    verify_installations

    echo ""
    print_success "Development tools installation complete!"
    echo ""
    print_info "Next steps:"
    echo "  • Test Docker compatibility: docker ps"
    echo "  • Authenticate GitHub CLI: gh auth login"
    echo "  • Verify kubectl: kubectl version --client"
    echo "  • Install a Python version: pyenv install 3.12"
    echo "  • Set global Python: pyenv global 3.12"
    echo "  • Create a project with uv: uv init myproject"
    echo "  • Configure AWS: aws configure"
    echo ""
    
    # Ensure git is configured before suggesting gh auth
    # This will only prompt if git identity is not set
    if command_exists gh; then
        ensure_git_configured
    fi
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
