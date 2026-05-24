#!/bin/bash
# macOS system preferences and UI customizations
# Configure Finder, Dock, trackpad, keyboard, and more

set -e

# Load utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils.sh"
source "$SCRIPT_DIR/utils-macos.sh"

configure_macos() {
    print_step "Configuring macOS System Preferences"
    
    if ! is_macos; then
        print_warning "Not running on macOS, skipping system preferences"
        return 0
    fi
    
    if ! ask_confirmation "Configure macOS system preferences?"; then
        print_info "Skipping macOS configuration"
        return 0
    fi
    
    # Close System Preferences to prevent conflicts
    if ! osascript -e 'tell application "System Preferences" to quit' 2>/dev/null; then
        # Not an error if System Preferences isn't running
        : # no-op
    fi
    
    print_info "Configuring UI/UX settings..."
    
    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    
    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true
    
    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    
    print_info "Configuring Finder..."
    
    # Finder: show hidden files by default
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Finder: show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Finder: show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Finder: show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    # Show the ~/Library folder
    if ! chflags nohidden ~/Library 2>/dev/null; then
        print_warning "Could not unhide ~/Library (may require permissions)"
    fi
    
    print_info "Configuring Dock..."
    
    # Set the icon size of Dock items (from config.sh)
    defaults write com.apple.dock tilesize -int "${DOCK_ICON_SIZE:-48}"
    
    # Minimize windows into their application's icon (disabled)
    defaults write com.apple.dock minimize-to-application -bool false
    
    # Show indicator lights for open applications in the Dock
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false
    
    # Automatically hide and show the Dock
    defaults write com.apple.dock autohide -bool true
    
    # Remove the auto-hiding Dock delay (from config.sh)
    defaults write com.apple.dock autohide-delay -float "${DOCK_AUTOHIDE_DELAY:-0}"
    
    # Speed up the animation when hiding/showing the Dock (from config.sh)
    defaults write com.apple.dock autohide-time-modifier -float "${DOCK_ANIMATION_SPEED:-0.5}"
    
    print_info "Configuring trackpad and keyboard..."
    
    # Trackpad: enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    
    # Enable full keyboard access for all controls
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
    
    print_info "Configuring keyboard layouts..."
    
    # Add Spanish and English US International - PC keyboard layouts
    # Check if layouts are already present to avoid duplicates
    local current_layouts=$(defaults read com.apple.HIToolbox AppleEnabledInputSources 2>/dev/null || echo "")
    
    # Keyboard layout IDs from config.sh
    local spanish_id="${KEYBOARD_SPANISH_ISO_ID:-87}"
    local us_intl_id="${KEYBOARD_US_INTL_PC_ID:-15000}"
    
    if ! echo "$current_layouts" | grep -q "Spanish - ISO"; then
        print_info "Adding Spanish - ISO keyboard layout..."
        defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
            "<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>$spanish_id</integer><key>KeyboardLayout Name</key><string>Spanish - ISO</string></dict>"
        print_success "Added Spanish keyboard layout"
    else
        print_info "Spanish - ISO keyboard layout already present"
    fi
    
    if ! echo "$current_layouts" | grep -q "USInternational-PC"; then
        print_info "Adding English US International - PC keyboard layout..."
        defaults write com.apple.HIToolbox AppleEnabledInputSources -array-add \
            "<dict><key>InputSourceKind</key><string>Keyboard Layout</string><key>KeyboardLayout ID</key><integer>$us_intl_id</integer><key>KeyboardLayout Name</key><string>USInternational-PC</string></dict>"
        print_success "Added English US International - PC keyboard layout"
    else
        print_info "English US International - PC keyboard layout already present"
    fi
    
    print_info "Configuring default applications..."
    
    # Set VSCodium as default editor for common file types
    if [ -d "$HOME/Applications/VSCodium.app" ] || [ -d "/Applications/VSCodium.app" ]; then
        print_info "Setting VSCodium as default editor..."
        defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
            '{LSHandlerContentType=public.plain-text;LSHandlerRoleAll=com.vscodium;}'
        defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
            '{LSHandlerContentType=public.source-code;LSHandlerRoleAll=com.vscodium;}'
        print_success "Set VSCodium as default editor"
    else
        print_info "VSCodium not found, skipping default editor setup"
    fi
    
    # Set WezTerm as default terminal
    if [ -d "$HOME/Applications/WezTerm.app" ] || [ -d "/Applications/WezTerm.app" ]; then
        print_info "Setting WezTerm as default terminal..."
        defaults write com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers -array-add \
            '{LSHandlerContentType=public.unix-executable;LSHandlerRoleShell=com.github.wez.wezterm;}'
        print_success "Set WezTerm as default terminal"
    else
        print_info "WezTerm not found, skipping default terminal setup"
    fi
    
    print_info "Restarting affected applications..."
    
    # Kill affected applications
    for app in "Dock" "Finder"; do
        if ! killall "${app}" &> /dev/null; then
            print_warning "Could not restart ${app} (may not be running)"
        fi
    done
    
    print_success "macOS configuration complete!"
    print_warning "Some changes may require a logout/restart to take full effect"
}

main() {
    configure_macos
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
