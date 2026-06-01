# stow/apps/

OS-specific Stow package for web app shortcuts as native-feeling desktop entries.

## Status

**OS-specific** — Linux only. Stowed by `scripts/pacman/07-stow.sh` (and future `apt/` and `dnf/` equivalents). Never stowed by `scripts/brew/06-stow.sh`.

## How it works

Each app is a `.desktop` file that launches a browser in `--app` mode, stripped of all browser UI. Chromium is used as the launcher.

XDG lookup paths used:
- Desktop entries: `~/.local/share/applications/`
- Icons: `~/.local/share/icons/hicolor/scalable/apps/`

## Adding an app

1. Drop a `.desktop` file in `stow/apps/.local/share/applications/`
2. Drop an SVG icon named to match the `Icon=` field in `stow/apps/.local/share/icons/hicolor/scalable/apps/`
3. Re-stow: `stow -t $HOME apps` from the `stow/` directory

## Apps

| App | URL | Icon |
|---|---|---|
| WhatsApp | https://web.whatsapp.com | `whatsapp.svg` (add manually) |

## Icons

Icons are not committed — drop your own SVG into:

```
stow/apps/.local/share/icons/hicolor/scalable/apps/whatsapp.svg
```

A suitable icon can be found via the [WhatsApp brand assets](https://about.meta.com/brand/resources/whatsapp/whatsapp-brand/).
