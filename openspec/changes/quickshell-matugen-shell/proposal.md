## Why

The current setup uses `caelestia-shell` (an opinionated upstream quickshell config) which limits customization. Material You theming via `matugen` works well at build time, but home-manager fully controls `~/.config` — making runtime theme changes (wallpaper → color regen → live reload) require a full rebuild. A custom quickshell shell with a wallpaper picker needs a dynamic theming pipeline that survives outside the Nix rebuild cycle.

## What Changes

- Replace `caelestia-shell` with a custom quickshell configuration maintained in this repo
- Add a wallpaper picker UI component in quickshell
- Establish a **runtime theming strategy**: key theme config dirs (`~/.config/quickshell/colors/`, `~/.config/matugen/`) are left **unmanaged by home-manager** so `matugen` can write to them at runtime
- A wallpaper change triggers: `matugen` reruns → writes color tokens → quickshell reloads → GTK4/Qt/terminal themes update
- Apply matugen-generated palette to **GTK4** (via `gtk.css` override), **Qt** (via `qt5ct`/`qt6ct` color scheme), and **terminal emulators** (color scheme files) at runtime — no rebuild required
- NixOS specialisations are **not used** — they require rebuilds and are unsuitable for dynamic wallpaper/color switching
- Affected hosts: **alcedo** (desktop), **hirundo** (laptop)
- Affected modules: `modules/home/user/desktop/`, `modules/home/user/theme/`, `modules/home/user/desktop/programs/`, potentially a new `modules/home/user/desktop/wayland/quickshell/`

## Capabilities

### New Capabilities

- `quickshell-shell`: Custom quickshell shell config — bar, launchers, notifications, and other shell components managed as source in this repo and symlinked/installed via home-manager
- `wallpaper-matugen-picker`: Quickshell wallpaper picker component that on selection runs matugen, generates Material You palettes, and triggers a quickshell reload
- `writable-theme-dirs`: Strategy module that ensures theme output directories (`~/.config/quickshell/colors/`, etc.) are not owned by home-manager, allowing runtime writes from matugen
- `app-theming-matugen`: Runtime application of matugen color tokens to GTK4 (`gtk.css`), Qt (`qt5ct`/`qt6ct` color scheme files), and terminal emulators (e.g., kitty/alacritty color config) — triggered on each wallpaper change alongside quickshell reload

### Modified Capabilities

(none — no existing specs)

## Impact

- `flake.nix`: `caelestia-shell` input may be removed or kept as reference
- `modules/home/user/theme/default.nix`: adjusted to not manage matugen output paths
- `modules/home/user/desktop/gtk.nix` / `qt.nix`: may need runtime-writable overrides for GTK4 css and Qt color scheme dirs
- `modules/home/user/desktop/programs/emulators/`: kitty and alacritty color configs left unmanaged (or templated) so matugen can rewrite them
- New module: `modules/home/user/desktop/wayland/quickshell/`
- `config/home/alcedo/joka/` and `config/home/hirundo/joka/`: enable new quickshell module
- No SOPS changes needed
- No server hosts affected

## Non-goals

- Per-host specialisations or NixOS-level theme variants
- Theming apps that don't read color configs from files (e.g., apps needing a full restart to pick up colors)
- Multi-user theming support
- Electron app theming (separate concern)
