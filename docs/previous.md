

## Things done manually

- Run Cachy Update

- Cachy OS Apps/Tweaks

    - Install Gaming Packages
    - Install WinBoat
    - Change DNS 

- Desktop apps
    - Install discord: sudo pacman -S discord
    - Install chromium: sudo pacman -S discord
    - Install vscodium: sudo pacman -S vscodium

- Flatpacks
    - Synology Drive

- Terminal apps
    - Install ollama: curl -fsSL https://ollama.com/install.sh | sh
    - Install opencode: curl -fsSL https://opencode.ai/install | bash

- Set Firefox as default browser and pdf files

- UI
    - Bottom panel settings, pannel height increased to 42
    - Also increased all font sizes from 10 to 11, small from 8 to 9. 

- Gaming: https://wiki.cachyos.org/configuration/gaming/
    - sudo pacman -S cachyos/umu-launcher

- Borderless windowed game stays on top when alt-tabbing fix
    - Use gamescope to wrap the game — it creates a proper KDE-managed window the compositor controls
    - Per-game: Steam → right-click game → Properties → Launch Options:
      `gamescope -W 2560 -H 1440 -r 144 --steam -- %command%`
    - All games: create `~/.local/bin/steam-gamescope` with:
      `exec gamescope -W 2560 -H 1440 -r 144 --steam -e -- steam "$@"`
      then `chmod +x` it and launch Steam via that script (`-e` = embedded session, all games inherit gamescope)
    - On KDE Wayland gamescope auto-uses nested Wayland mode — no extra flags needed

- Steam Big Picture opens on wrong monitor fix
    - Steam uses SDL which ignores the X11 primary monitor setting under XWayland/Wayland
    - Fix: override the Steam desktop entry to prepend `SDL_VIDEO_FULLSCREEN_DISPLAY=0`
    - Copied `/usr/share/applications/steam.desktop` to `~/.local/share/applications/steam.desktop`
    - Changed `Exec=/usr/bin/steam %U` to `Exec=env SDL_VIDEO_FULLSCREEN_DISPLAY=0 /usr/bin/steam %U`
    - The index (0 or 1) refers to SDL's display enumeration order — 0 matched DP-1 (primary, ASUS)