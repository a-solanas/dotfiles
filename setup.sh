#!/bin/bash
# Dotfiles Setup Orchestrator
# Detects the current OS/distro and delegates to the appropriate scripts subtree

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="$SCRIPT_DIR/scripts"

source "$SCRIPTS_DIR/utils.sh"

# ─── Help ─────────────────────────────────────────────────────────────────────

usage() {
    print_banner "Dotfiles Setup Script"
    echo -e "  ${BOLD}Usage:${NC}   ./setup.sh [option]"
    echo ""
    echo -e "  ${BOLD}Options:${NC}"
    echo -e "    ${CYAN}-h, --help${NC}     Show this help"
    echo -e "    ${CYAN}--pwner${NC}        Set up offensive security environment"
    echo -e "                   Auto-detects Kali; otherwise runs custom Debian setup"
    echo ""
    echo -e "  ${BOLD}Auto-detected distros:${NC}"
    echo -e "    ${GREEN}Arch / CachyOS${NC}   →  scripts/pacman/"
    echo -e "    ${GREEN}Debian / Mint${NC}    →  scripts/apt/"
    echo -e "    ${GREEN}Fedora${NC}           →  scripts/dnf/"
    echo -e "    ${GREEN}macOS${NC}            →  scripts/brew/"
    echo ""
    echo -e "  ${BOLD}Manual only:${NC}"
    echo -e "    ${YELLOW}Kali${NC}             →  ./setup.sh --pwner  (auto-detected within pwner)"
    echo ""
    echo -e "  ${BOLD}Examples:${NC}"
    echo "    ./setup.sh              Normal setup for the current distro"
    echo "    ./setup.sh --pwner      Offensive security environment"
    echo ""
}

# ─── Pwner ────────────────────────────────────────────────────────────────────

run_pwner() {
    local pwner_dir="$SCRIPTS_DIR/pwner"
    local target_script=""

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ "$ID" == "kali" ]]; then
            print_info "Kali Linux detected"
            target_script="$pwner_dir/kali/setup.sh"
        fi
    fi

    if [ -z "$target_script" ]; then
        print_info "No Kali detected — using custom Debian offensive setup"
        target_script="$pwner_dir/setup.sh"
    fi

    if [ ! -f "$target_script" ]; then
        print_error "Pwner script not found: $target_script"
        print_info  "This target hasn't been implemented yet."
        exit 1
    fi

    print_banner "Pwner Setup"
    bash "$target_script"
}

# ─── Normal setup ─────────────────────────────────────────────────────────────

run_setup() {
    print_banner "Dotfiles Setup Script"

    local distro_scripts=""

    if [ -f /etc/os-release ]; then
        . /etc/os-release

        # Kali must be set up via --pwner, not the normal flow
        if [[ "$ID" == "kali" ]]; then
            print_error "Kali Linux detected."
            print_info  "Use './setup.sh --pwner' to set up this machine."
            exit 1
        fi

        case "${ID_LIKE:-$ID}" in
            *arch*)                   distro_scripts="$SCRIPTS_DIR/pacman" ;;
            *debian*|*ubuntu*)        distro_scripts="$SCRIPTS_DIR/apt"    ;;
            *fedora*|*rhel*|*centos*) distro_scripts="$SCRIPTS_DIR/dnf"    ;;
            *)
                print_error "Unsupported distro: ${ID} (ID_LIKE: ${ID_LIKE:-none})"
                print_info  "Run './setup.sh --help' to see supported targets."
                exit 1
                ;;
        esac
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        distro_scripts="$SCRIPTS_DIR/brew"
    else
        print_error "Cannot detect OS — /etc/os-release not found and not macOS."
        exit 1
    fi

    if [ ! -d "$distro_scripts" ]; then
        print_error "Scripts not found: $distro_scripts"
        print_info  "This distro target hasn't been implemented yet."
        exit 1
    fi

    print_info "Distro:  ${ID:-macOS}"
    print_info "Scripts: $distro_scripts"
    echo ""

    if ! ask_confirmation "Continue with setup?"; then
        print_info "Setup cancelled."
        exit 0
    fi

    local scripts
    mapfile -t scripts < <(find "$distro_scripts" -maxdepth 1 -name '[0-9][0-9]-*.sh' | sort)
    local total=${#scripts[@]}
    local current=0

    for script in "${scripts[@]}"; do
        ((current++))
        local script_name step_name
        script_name=$(basename "$script" .sh)
        step_name=$(echo "$script_name" | sed 's/^[0-9]*-//' | tr '-' ' ' \
            | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')
        print_step "Step $current/$total: $step_name"
        bash "$script"
    done

    echo ""
    print_banner "Setup Complete!"
    echo ""
    echo -e "${CYAN}Next steps:${NC}"
    echo "  1. Restart your terminal or run: exec fish"
    echo "  2. Your dotfiles are symlinked from: $SCRIPT_DIR"
    echo "  3. Edit configs directly in this directory to make changes"
    echo ""
    print_info "Logs: $DOTFILES_LOG_FILE"
    echo ""
}

# ─── Entry point ──────────────────────────────────────────────────────────────

main() {
    case "${1:-}" in
        -h|--help) usage      ;;
        --pwner)   run_pwner  ;;
        "")        run_setup  ;;
        *)
            print_error "Unknown option: $1"
            echo ""
            usage
            exit 1
            ;;
    esac
}

main "$@"
