# WezTerm Config Notes

Config lives at `stow/wezterm/.config/wezterm/wezterm.lua`. Stowed on all OSes.

## Cross-platform strategy

Mac and Linux diverge in a few places. All divergence is gated with `wezterm.target_triple:find('apple')`. Mac guards are kept even when macOS is dormant — the cost is trivial and the personal Mac is an eventual target.

## Decisions

### Window decorations

- **macOS**: `INTEGRATED_BUTTONS|RESIZE` — traffic lights integrated into the WezTerm frame, no system title bar.
- **Linux (KDE Wayland)**: `RESIZE` only — no title bar, no integrated buttons. Window is moved via `Meta+drag` (KDE global shortcut). KDE applies server-side decorations (border, shadow) regardless.

`TITLE|RESIZE` and `INTEGRATED_BUTTONS|RESIZE` were both tried on Linux. `TITLE|RESIZE` showed an ugly KDE title bar. `INTEGRATED_BUTTONS` rendered poorly with the retro tab bar style (`use_fancy_tab_bar = false`) and button colour properties (`window_frame.button_fg/bg`) have no effect in that mode.

### Keybindings — OS-split tables (pending)

The design calls for two separate tables (`mac_keys`, `linux_keys`) rather than a single table with inline guards. See [ADR-0003](adr/0003-wezterm-os-split-key-tables.md).

**This is not yet implemented.** The current `wezterm.lua` uses a single `config.keys` table with `CMD` throughout. On Linux, `CMD` maps to Super, which conflicts with KDE bindings (e.g. Super+D = show desktop). Tracked in `.scratch/wezterm-keybindings/issues/01-os-split-key-tables.md`.

**Planned macOS table** — `CMD` (⌘) throughout, unambiguously owned by apps.

**Planned Linux table** — hybrid strategy:
- `CTRL+S` for smart split — Super+D conflicts with KDE show-desktop. See [ADR-0004](adr/0004-wezterm-ctrl-s-smart-split-linux.md).
- `Super+Shift` for window-level utilities (reload, debug overlay, copy mode, transparency, cheat).
- Font size and close-pane bindings **omitted** on Linux — `Ctrl+=/−` and `Ctrl+D` (EOF) handle these natively.

### Mouse selection

Defining any `config.mouse_bindings` can displace WezTerm's built-in left-click defaults. The full set of left-click bindings (Down/Drag/Up for streak 1/2/3) must be declared explicitly alongside any custom entries, otherwise dragging and double/triple-click selection stop working.
