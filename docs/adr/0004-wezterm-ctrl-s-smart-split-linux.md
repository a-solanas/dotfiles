# CTRL+S repurposed for smart split on Linux

Smart split needed a Linux binding after CMD+D (Super+D) was dropped due to its conflict with KDE's show-desktop shortcut. CTRL+S was chosen over the safer CTRL+SHIFT+D because XOFF (the freeze-output signal that CTRL+S normally sends) is a legacy flow-control artifact with no practical use in modern terminal emulators — it's a footgun more than a feature.

WezTerm intercepts CTRL+S before it reaches the PTY, so XOFF is fully retired within a WezTerm session. Any future neovim or TUI config that would otherwise map CTRL+S to save must account for this being taken at the terminal level.
