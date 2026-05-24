# Scripts named by package manager, not distro

Install scripts under `scripts/` are named after the package manager (`pacman/`, `apt/`, `dnf/`, `brew/`) rather than the distro (`arch/`, `debian/`, `fedora/`, `macos/`). From the install script's perspective a distro is just a package-manager ecosystem — Mint, Ubuntu, and Debian all reduce to `apt`, and CachyOS and Arch both reduce to `pacman`. Naming by package manager makes the grouping rule explicit and avoids the need to enumerate every distro variant in the detection logic.
