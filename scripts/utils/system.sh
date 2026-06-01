#!/bin/bash
# System and architecture detection

# Returns: amd64, arm64, armv7, or raw uname -m output
get_arch() {
    case "$(uname -m)" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        armv7l)  echo "armv7" ;;
        *)       echo "$(uname -m)" ;;
    esac
}

# Returns the ID_LIKE or ID from /etc/os-release, or "darwin" on macOS
get_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "${ID_LIKE:-$ID}"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "darwin"
    else
        echo "unknown"
    fi
}

# Returns the exact distro ID (e.g. "cachyos", "ubuntu", "fedora")
get_distro_id() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    fi
}
