# ══════════════════════════════════════════════════════════════════════════════
# Fish Shell Configuration
# ══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# Disable greeting
# ─────────────────────────────────────────────────────────────────────────────
set -g fish_greeting

# ─────────────────────────────────────────────────────────────────────────────
# PATH Configuration
# ─────────────────────────────────────────────────────────────────────────────
if test (uname) = Darwin
    fish_add_path /opt/homebrew/bin
    fish_add_path /opt/homebrew/sbin
    fish_add_path /usr/local/bin
    fish_add_path /usr/local/sbin
end
fish_add_path $HOME/.local/bin

# ─────────────────────────────────────────────────────────────────────────────
# Tool Initialization (lazy-loaded for faster shell startup)
# ─────────────────────────────────────────────────────────────────────────────
# Starship prompt - must load eagerly for prompt rendering
starship init fish | source

# Zoxide (smarter cd) - lazy: initialize on first use of z/cd
if not functions -q __zoxide_initialized
    zoxide init fish | source
    function __zoxide_initialized; end
end

# fzf key bindings - lazy: defer until first interactive key
# Default bindings: Ctrl+R (history), Ctrl+T (files), Alt+C (cd)
if status is-interactive
    # Use fd for faster file search, exclude .git
    set -gx FZF_CTRL_T_COMMAND 'fd --type f --hidden --exclude .git'
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --exclude .git'
    fzf --fish | source
    
    # macOS-friendly file search: Cmd+T (in addition to Ctrl+T)
    bind \e\[116\;9u fzf-file-widget  # Ctrl+T fallback
end

# Editor shell integration (terminal launched from inside the editor)
if test "$TERM_PROGRAM" = "vscode"
    if test (uname) = Darwin
        . (code --locate-shell-integration-path fish)
    else
        . (codium --locate-shell-integration-path fish)
    end
end

# ─────────────────────────────────────────────────────────────────────────────
# Environment Variables
# ─────────────────────────────────────────────────────────────────────────────
if test (uname) = Darwin
    set -gx EDITOR code
else
    set -gx EDITOR codium
end

# fzf configuration (customize appearance and behavior)
set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=bg+:#3e4451,fg+:#ffffff,hl:#81a2be,hl+:#7aa6da'

# Dotfiles root — used by the cheat function and the dotfiles abbreviation
set -gx DOTFILES_DIR "$HOME/Developer/dotfiles"

# ══════════════════════════════════════════════════════════════════════════════
# SYSTEM/PERSONAL CONFIGURATION
# ══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────
# Abbreviations - General
# ─────────────────────────────────────────────────────────────────────────────
abbr fishconfig "$EDITOR ~/.config/fish/config.fish"
abbr dotfiles "$EDITOR $DOTFILES_DIR"

# Modern CLI replacements (abbreviations expand inline for transparency)
abbr find fd
abbr grep rg
abbr ls eza
abbr ll "eza -la"
abbr tree "eza --tree"
abbr ff fastfetch

# Use zoxide for directory navigation (alias needed to override cd command)
alias cd "z"

# Reload Fish config (alias needed for command expansion)
alias reload "source ~/.config/fish/config.fish"

# Clear screen without erasing scrollback (move cursor home + clear visible screen only)
bind \cl 'printf "\033[H\033[2J"; commandline -f repaint'

# Expand abbreviation under cursor with Alt+Space (without executing)
bind \e\  'commandline -f expand-abbr'

# ─────────────────────────────────────────────────────────────────────────────
# Abbreviations - Python (uv)
# ─────────────────────────────────────────────────────────────────────────────
abbr python python3
abbr uvr "uv run"
abbr uva "uv add"
abbr uvs "uv sync"
abbr uvi "uv init"

# ─────────────────────────────────────────────────────────────────────────────
# Container Aliases (Podman/Docker - aliases needed for command override)
# ─────────────────────────────────────────────────────────────────────────────
alias docker podman
alias docker-compose podman-compose
abbr lzd lazydocker

# Uncomment if tools aren't picking up the Podman socket (e.g. after switching from Docker Desktop)
# set -gx DOCKER_HOST "unix:///var/run/docker.sock"


# ─────────────────────────────────────────────────────────────────────────────
# Cheatsheet
# ─────────────────────────────────────────────────────────────────────────────
# Usage: cheat          → full cheatsheet
#        cheat wez      → only wezterm section
#        cheat dev      → only dev-tools section
function cheat
    set -l dir $DOTFILES_DIR/docs/cheatsheet

    if test (count $argv) -gt 0
        set -l match (find $dir -iname "*$argv[1]*" -name "*.md" | sort | head -1)
        if test -n "$match"
            if command -v glow >/dev/null
                glow -p "$match"
            else if command -v bat >/dev/null
                bat "$match"
            else
                cat "$match"
            end
        else
            echo "No section matching '$argv[1]'. Available:"
            for f in $dir/*.md
                basename $f .md | string replace -r '^\d+-' '  • '
            end
        end
    else
        if command -v glow >/dev/null
            cat $dir/*.md | glow -p
        else if command -v bat >/dev/null
            cat $dir/*.md | bat -l md --plain
        else
            cat $dir/*.md
        end
    end
end

# ─────────────────────────────────────────────────────────────────────────────
# Startup
# ─────────────────────────────────────────────────────────────────────────────
# Only run fastfetch on new terminal instances (not nested shells)
# SHLVL=1 means this is the first shell, not a subshell
if test $COLUMNS -ge 80 -a $LINES -ge 50 -a "$SHLVL" -eq 1
    fastfetch
end
