# WezTerm keybindings split into OS-specific tables

WezTerm is stowed on all OSes, but `CMD` maps to ⌘ on macOS and to Super on Linux, where Super is owned by KDE. This makes the modifier strategies structurally different across platforms — macOS uses CMD throughout, Linux uses CTRL for pane management and Super+Shift for window-level utilities. Because of this structural divergence, keybindings are maintained as two separate tables (`mac_keys`, `linux_keys`) assigned to `config.keys` via the existing `target_triple` OS guard, rather than a single table with inline conditional entries.

The alternative — patching only the conflicting entries inline — was rejected because it makes it hard to audit which bindings are active on a given platform. Two named tables make each platform's binding set independently readable.
