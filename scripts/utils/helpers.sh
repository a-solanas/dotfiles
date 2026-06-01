#!/bin/bash
# General-purpose shell helpers
# Requires colors.sh and logging.sh to be sourced first

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

ask_confirmation() {
    local question="$1"
    local default="${2:-y}"
    local prompt="[Y/n]"
    [ "$default" != "y" ] && prompt="[y/N]"
    read -p "$(echo -e "${CYAN}$question $prompt${NC} ")" response
    response=${response:-$default}
    [[ "$response" =~ ^[Yy]$ ]]
}

validate_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
}

validate_name() {
    [ "$(echo "$1" | wc -w | tr -d ' ')" -ge 2 ]
}

ensure_git_configured() {
    local current_name current_email
    current_name=$(git config --global user.name 2>/dev/null || echo "")
    current_email=$(git config --global user.email 2>/dev/null || echo "")

    if [ -n "$current_name" ] && [ -n "$current_email" ]; then
        log_to_file "Git already configured: $current_name <$current_email>"
        return 0
    fi

    print_step "Configuring Git Identity"

    if [ -n "${GIT_USER_NAME:-}" ] && [ -n "${GIT_USER_EMAIL:-}" ]; then
        git config --global user.name "$GIT_USER_NAME"
        git config --global user.email "$GIT_USER_EMAIL"
        print_success "Git configured from environment variables"
        return 0
    fi

    local git_name="$current_name"
    while true; do
        [ -z "$git_name" ] && read -p "$(echo -e "${BLUE}?${NC} Full name (First Last): ")" git_name
        [ -z "$git_name" ] && { print_error "Name cannot be empty"; continue; }
        validate_name "$git_name" || { print_error "Please enter first and last name"; git_name=""; continue; }
        break
    done

    local git_email="$current_email"
    while true; do
        [ -z "$git_email" ] && read -p "$(echo -e "${BLUE}?${NC} Email address: ")" git_email
        [ -z "$git_email" ] && { print_error "Email cannot be empty"; continue; }
        validate_email "$git_email" || { print_error "Invalid email address"; git_email=""; continue; }
        break
    done

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    print_success "Git configured: $git_name <$git_email>"
    log_to_file "Git configured: $git_name <$git_email>"
}
