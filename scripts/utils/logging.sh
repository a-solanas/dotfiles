#!/bin/bash
# Logging, banners, and output helpers
# Requires colors.sh to be sourced first

# Print a centered banner. Each argument is a line.
# Falls back to plain print if any line exceeds the inner box width (54 chars).
# TODO: support dynamic box sizing for long text
print_banner() {
    local inner=54
    local lines=("$@")

    for line in "${lines[@]}"; do
        if [ ${#line} -gt "$inner" ]; then
            echo -e "${CYAN}"
            for l in "${lines[@]}"; do echo "  $l"; done
            echo -e "${NC}"
            return
        fi
    done

    local border blank
    border=$(printf '═%.0s' $(seq 1 "$inner"))
    blank=$(printf '%*s' "$inner" '')

    echo -e "${CYAN}"
    echo "╔${border}╗"
    echo "║${blank}║"

    for line in "${lines[@]}"; do
        local len=${#line}
        local lpad rpad
        lpad=$(printf '%*s' "$(( (inner - len) / 2 ))" '')
        rpad=$(printf '%*s' "$(( inner - len - (inner - len) / 2 ))" '')
        echo "║${lpad}${line}${rpad}║"
    done

    echo "║${blank}║"
    echo "╚${border}╝"
    echo -e "${NC}"
}

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error()   { echo -e "${RED}✗${NC} $1"; }
print_info()    { echo -e "${BLUE}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_step()    { echo -e "\n${MAGENTA}==>${NC} ${BOLD}$1${NC}"; }

log_to_file() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "${DOTFILES_LOG_FILE}"
}

handle_error() {
    print_error "$1"
    log_to_file "ERROR: $1"
    exit 1
}
