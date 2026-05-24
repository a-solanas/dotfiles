#!/bin/bash
# Pwner: Debian VM Bootstrap Script
# Run after fix-dns.sh to set up your security VM

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_step() { echo -e "${GREEN}==> $1${NC}"; }
print_info() { echo -e "${YELLOW}    $1${NC}"; }
print_error() { echo -e "${RED}ERROR: $1${NC}"; }

# Get script directory for sourcing modules
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
USERNAME="${SUDO_USER:-pwner}"

# Arch detection
case "$(uname -m)" in
    x86_64)  ARCH="x86_64";  ARCH_ALT="amd64"  ;;
    aarch64) ARCH="aarch64"; ARCH_ALT="arm64"   ;;
    *)       ARCH="$(uname -m)"; ARCH_ALT="$ARCH" ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# Sudo Setup (run as root first time)
# ─────────────────────────────────────────────────────────────────────────────
setup_sudo() {
    if ! command -v sudo &>/dev/null; then
        echo "Installing sudo (run this as root)..."
        apt update && apt install -y sudo
    fi

    if ! groups "$USERNAME" | grep -q sudo; then
        echo "Adding $USERNAME to sudo group..."
        usermod -aG sudo "$USERNAME"
        echo "Sudo configured for $USERNAME"
        echo "Log out and back in, then run this script again as $USERNAME"
        exit 0
    fi
}

# If running as root, setup sudo and exit
if [ "$(id -u)" -eq 0 ]; then
    setup_sudo
fi

# ─────────────────────────────────────────────────────────────────────────────
# System Update
# ─────────────────────────────────────────────────────────────────────────────
print_step "Updating system..."
sudo apt update && sudo apt upgrade -y

# ─────────────────────────────────────────────────────────────────────────────
# Base Utilities
# ─────────────────────────────────────────────────────────────────────────────
print_step "Installing base utilities..."
sudo apt install -y \
    git \
    curl \
    wget \
    build-essential \
    unzip \
    jq \
    bat \
    fd-find \
    ripgrep \
    fzf

# ─────────────────────────────────────────────────────────────────────────────
# Modern CLI Tools (from GitHub releases - not in Debian repos)
# ─────────────────────────────────────────────────────────────────────────────
print_step "Installing modern CLI tools..."

# eza (modern ls)
if ! command -v eza &>/dev/null; then
    print_info "Installing eza..."
    sudo apt install -y gpg
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo apt update && sudo apt install -y eza
fi

# zoxide (smart cd)
if ! command -v zoxide &>/dev/null; then
    print_info "Installing zoxide..."
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi

# starship (prompt)
if ! command -v starship &>/dev/null; then
    print_info "Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# neovim (latest)
if ! command -v nvim &>/dev/null; then
    print_info "Installing neovim..."
    curl -L -o /tmp/nvim-linux-${ARCH}.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${ARCH}.tar.gz
    sudo tar -C /opt -xzf /tmp/nvim-linux-${ARCH}.tar.gz
    sudo ln -sf /opt/nvim-linux-${ARCH}/bin/nvim /usr/local/bin/nvim
    rm -f /tmp/nvim-linux-${ARCH}.tar.gz
fi

# btop (resource monitor)
if ! command -v btop &>/dev/null; then
    print_info "Installing btop..."
    sudo apt install -y btop || {
        # Fallback to GitHub release if not in repos
        curl -L -o /tmp/btop-${ARCH}-linux-musl.tbz https://github.com/aristocratos/btop/releases/latest/download/btop-${ARCH}-linux-musl.tbz
        sudo tar -xjf /tmp/btop-${ARCH}-linux-musl.tbz -C /usr/local --strip-components=2
        rm -f /tmp/btop-${ARCH}-linux-musl.tbz
    }
fi

# ─────────────────────────────────────────────────────────────────────────────
# Fish Shell
# ─────────────────────────────────────────────────────────────────────────────
print_step "Installing Fish shell..."
sudo apt install -y fish

# Set fish as default shell
if [ "$SHELL" != "$(which fish)" ]; then
    print_info "Setting fish as default shell..."
    chsh -s "$(which fish)"
    print_info "Fish set as default. Log out and back in to use it."
fi

# ─────────────────────────────────────────────────────────────────────────────
# GUI Apps (KDE desktop)
# ─────────────────────────────────────────────────────────────────────────────
print_step "Installing GUI applications..."

# Firefox
if ! command -v firefox &>/dev/null; then
    print_info "Installing Firefox..."
    sudo apt install -y firefox-esr
fi

# VSCodium
if ! command -v codium &>/dev/null; then
    print_info "Installing VSCodium..."
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install -y codium
fi

# Wezterm
if ! command -v wezterm &>/dev/null; then
    print_info "Installing Wezterm..."
    curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
    echo 'deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *' | sudo tee /etc/apt/sources.list.d/wezterm.list
    sudo apt update && sudo apt install -y wezterm
fi

# ─────────────────────────────────────────────────────────────────────────────
# Optional Modules
# ─────────────────────────────────────────────────────────────────────────────
echo ""
print_step "Optional modules:"
echo "  1) recon   - nmap, masscan, amass"
echo "  2) web     - gobuster, ffuf, sqlmap, nikto"
echo "  3) crack   - john"
echo "  4) all     - install everything"
echo "  5) skip    - skip optional modules"
echo ""
read -p "Select modules (comma-separated, e.g., 1,2): " module_choice

install_module() {
    local module="$1"
    local module_file="$SCRIPT_DIR/modules/${module}.sh"
    if [ -f "$module_file" ]; then
        print_step "Installing $module module..."
        source "$module_file"
    else
        print_info "Module $module not found, skipping..."
    fi
}

case "$module_choice" in
    *1*) install_module "recon" ;;&
    *2*) install_module "web" ;;&
    *3*) install_module "crack" ;;&
    *4*|*all*)
        install_module "recon"
        install_module "web"
        install_module "crack"
        ;;
    *5*|*skip*|"") print_info "Skipping optional modules" ;;
esac

# ─────────────────────────────────────────────────────────────────────────────
# SecLists (wordlists)
# ─────────────────────────────────────────────────────────────────────────────
print_step "Installing SecLists..."
if [ ! -d /opt/seclists ]; then
    sudo git clone --depth 1 https://github.com/danielmiessler/SecLists.git /opt/seclists
    print_info "SecLists installed at /opt/seclists"
else
    print_info "SecLists already installed"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Done
# ─────────────────────────────────────────────────────────────────────────────
echo ""
print_step "Setup complete!"
print_info "Log out and back in to use fish shell"
print_info "Add more tools by creating modules in: $SCRIPT_DIR/modules/"
