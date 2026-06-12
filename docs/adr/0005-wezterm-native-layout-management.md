# WezTerm-native layout management, no local multiplexer

Session/layout management uses WezTerm's Lua API + `wezterm cli`, a fzf picker, and fish functions. No terminal multiplexer (tmux, zellij) is used for local work.

## Decision

Named layouts are defined as fish functions or config files. A WezTerm keybinding spawns a floating fzf pane listing available layouts and saved sessions. Selecting one runs `wezterm cli spawn` commands to recreate pane structure and CWDs. Session state (CWDs + running process names) is saved to `~/.config/wezterm/sessions/` via `wezterm cli list` and restored on demand.

## Rationale

Tmux and zellij were considered. Tmux's core strength — SSH session persistence so processes survive disconnect — does not apply to local desktop work. Zellij has better layout ergonomics but no reliable cross-reboot state restoration. Either multiplexer would conflict with WezTerm's own pane management, requiring a full commitment to the multiplexer as the split layer and adding config overhead for no local gain.

The WezTerm CLI already exposes pane CWDs and foreground process names, which is sufficient to reconstruct layouts. True process state (running servers, distrobox sessions, k3s clusters) cannot be portably saved and is excluded by design — the user restarts those manually.

## tmux/zellij retained for SSH

Both tools remain available for use inside SSH sessions on remote machines, where the detach/reattach use case is real. This is not configured in dotfiles — invoked ad-hoc on the remote side only.
