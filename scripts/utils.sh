#!/bin/bash
# Utility loader — sources global config and all utils/ modules.
# Scripts that need utilities should source this file.

_UTILS_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Global config (always)
source "$_UTILS_ROOT/config.sh"

# 2. Utils modules
source "$_UTILS_ROOT/utils/colors.sh"
source "$_UTILS_ROOT/utils/logging.sh"
source "$_UTILS_ROOT/utils/system.sh"
source "$_UTILS_ROOT/utils/helpers.sh"

# 3. Distro-specific config (optional — e.g. scripts/brew/config.sh)
_caller_dir="$(cd "$(dirname "${BASH_SOURCE[1]}")" && pwd 2>/dev/null || true)"
if [ -f "$_caller_dir/config.sh" ]; then
    source "$_caller_dir/config.sh"
fi

unset _UTILS_ROOT _caller_dir
