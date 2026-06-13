# WezTerm tab title format

Tab titles use fish's OSC 2 pane title, post-processed to be compact.

## Decision

Format: `{index}: {processed_pane_title}` where processing means:

1. Any path prefix (starting with `~` or `/`) is collapsed to its last component — `~/Developer/dotfiles` → `dotfiles`.
2. The ` - ` separator fish uses between path and process is replaced with ` > `.
3. `tab_max_width = 26` hard-caps each tab's width.

The raw `tab.active_pane.title` is used directly rather than independently computing CWD + foreground process, since fish already assembles the right information via its title function.

No guard against `wezterm.on()` accumulation is needed: WezTerm rebuilds its Lua state from scratch on each config reload, which clears all registered handlers before the config re-executes.

## Rationale

Computing CWD and process name separately from the pane title duplicated logic already handled by fish and caused drift (e.g. the shell-filter check hiding the process name). Using the OSC 2 title as the single source of truth is simpler and stays in sync with whatever fish decides to show.

Path collapsing and the `>` separator keep the tab bar scannable without scrolling. The index prefix is retained so tab positions are unambiguous when titles are truncated.
