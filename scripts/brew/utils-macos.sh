#!/bin/bash
# macOS-specific helpers — sourced by brew scripts after utils.sh

is_macos() {
    [[ "$OSTYPE" == "darwin"* ]]
}

is_arm64() {
    [[ "$(uname -m)" == "arm64" ]]
}
