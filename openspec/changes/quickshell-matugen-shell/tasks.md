## 1. Module Scaffold

- [x] 1.1 Create `modules/home/user/desktop/wayland/quickshell/default.nix` with `enable`, `wallpaperDir`, and `persist` options
- [ ] 1.2 Add the quickshell module to `modules/home/user/desktop/wayland/default.nix` (or equivalent entry)
- [ ] 1.3 Add `quickshell` flake input pin to `flake.nix` (already present — verify it's exposed to home-manager module args)

## 2. Writable Theme Dirs

- [x] 2.1 In the quickshell module, add a `home.activation` script that creates `~/.config/matugen/` and `~/.config/quickshell/colors/` if absent (affected: `modules/home/user/desktop/wayland/quickshell/default.nix`)
- [x] 2.2 Ensure `~/.config/matugen/` and `~/.config/quickshell/colors/` are NOT declared in `home.file` or `xdg.configFile` anywhere in the module
- [x] 2.3 Add impermanence warning: if `home.persistence` is defined but `quickshell.persist` is false, emit `lib.warn`
- [x] 2.4 When `quickshell.persist = true`, add `~/.config/matugen` and `~/.config/quickshell/colors` to `home.persistence` (affected: `modules/home/user/desktop/wayland/quickshell/default.nix`)

## 3. Quickshell QML Config

- [ ] 3.1 Create skeleton QML shell config at `modules/home/user/desktop/wayland/quickshell/config/shell.qml` (bar + notification area as minimal shell)
- [ ] 3.2 Add color import convention in QML: read token files from `~/.config/quickshell/colors/colors.json` (or matugen output format)
- [x] 3.3 Install QML sources via `home.file` as store symlinks in the module (e.g., `~/.config/quickshell/shell.qml`)
- [ ] 3.4 Bundle a default wallpaper in the module (small image in `modules/home/user/desktop/wayland/quickshell/assets/default-wallpaper.jpg`)
- [x] 3.5 In the activation script (2.1), run `matugen image <default-wallpaper>` if `~/.config/quickshell/colors/` is empty

## 4. Wallpaper Picker Component

- [ ] 4.1 Create `modules/home/user/desktop/wayland/quickshell/config/wallpaper-picker.qml` that lists images from `wallpaperDir`
- [ ] 4.2 On image selection: set wallpaper via `swaybg` (or `swww`) and run `matugen image <path>` as a subprocess
- [ ] 4.3 After matugen writes colors, signal quickshell to hot-reload (use quickshell IPC or file watcher on the colors dir)
- [ ] 4.4 Wire picker into the shell (keybind or bar button to open picker overlay)

## 5. Theme Module Integration

- [ ] 5.1 Audit `modules/home/user/theme/default.nix` — ensure it does not manage `~/.config/matugen/` paths that would conflict (affected: `modules/home/user/theme/default.nix`)
- [ ] 5.2 Remove or gate any `home.file` entries for matugen output dirs in the existing theme module

## 6. Host Enablement — alcedo

- [ ] 6.1 Enable quickshell module in `config/home/alcedo/joka/` — set `wallpaperDir` and `persist` as appropriate
- [ ] 6.2 Disable caelestia-shell in `config/home/alcedo/joka/` (or relevant desktop module)
- [ ] 6.3 Deploy with `nh home switch .` on alcedo and verify: bar visible, wallpaper picker works, matugen writes colors, quickshell reloads

## 7. Host Enablement — hirundo

- [ ] 7.1 Enable quickshell module in `config/home/hirundo/joka/` — set `persist = true` (hirundo uses impermanence if applicable)
- [ ] 7.2 Disable caelestia-shell on hirundo
- [ ] 7.3 Deploy with `nh home switch .` on hirundo and verify full theming pipeline

## 8. App Theming — GTK4

- [ ] 8.1 In `modules/home/user/desktop/gtk.nix`, remove any color values sourced from `config.theme.colorscheme.colors` that apply to GTK4
- [ ] 8.2 Ensure `~/.config/gtk-4.0/gtk.css` is NOT declared in `home.file` or `xdg.configFile` (leave unmanaged)
- [ ] 8.3 Add `~/.config/gtk-4.0/gtk.css` creation to the quickshell module activation script (run matugen GTK4 template on first boot if absent)
- [ ] 8.4 Add `~/.config/gtk-4.0` to `home.persistence` when `quickshell.persist = true` (affected: `modules/home/user/desktop/wayland/quickshell/default.nix`)
- [ ] 8.5 In the wallpaper picker script, after matugen writes `gtk.css`, send a GTK4 reload signal: toggle `gsettings set org.gnome.desktop.interface gtk-theme` (set to a dummy value then back) to force running GTK4 windows to re-read `gtk.css` live

## 9. App Theming — Qt

- [ ] 9.1 In `modules/home/user/desktop/qt.nix`, configure qt5ct/qt6ct to use color scheme path `~/.config/qt5ct/colors/matugen.conf` / `~/.config/qt6ct/colors/matugen.conf` via managed `qt5ct.conf` / `qt6ct.conf`
- [ ] 9.2 Ensure the color scheme files themselves (`~/.config/qt5ct/colors/matugen.conf`, `~/.config/qt6ct/colors/matugen.conf`) are NOT store-managed
- [ ] 9.3 Add matugen Qt template output to the wallpaper picker script
- [ ] 9.4 After writing Qt color scheme files, emit a D-Bus signal to trigger palette reload in running Qt apps: `qdbus org.kde.KWin /KWin reconfigure` or send `org.freedesktop.appearance` color-scheme property change via `gdbus`
- [ ] 9.5 Add `~/.config/qt5ct/colors` and `~/.config/qt6ct/colors` to `home.persistence` when `quickshell.persist = true`

## 10. App Theming — Kitty

- [ ] 10.1 In `modules/home/user/desktop/programs/emulators/kitty/default.nix`, remove all `foreground`/`background`/cursor/color palette settings sourced from `config.theme.colorscheme.colors`
- [ ] 10.2 Add `extraConfig = "include ~/.config/kitty/colors.conf";` to the kitty home-manager config so kitty reads runtime colors
- [ ] 10.3 Ensure `~/.config/kitty/colors.conf` is NOT declared in `xdg.configFile` (leave unmanaged)
- [ ] 10.4 Add `~/.config/kitty/colors.conf` to the activation script to generate from default wallpaper on first boot
- [ ] 10.5 In the wallpaper picker script, after matugen runs, call `kitty @ set-colors ~/.config/kitty/colors.conf` (or `kitten themes --reload-in=all`) to hot-reload running kitty instances
- [ ] 10.6 Add `~/.config/kitty/colors.conf` to `home.persistence` when `quickshell.persist = true`

## 11. Cleanup

- [ ] 11.1 Run `nix fmt` across all changed files
- [ ] 11.2 Run `nix flake check` and resolve any evaluation errors
- [ ] 11.3 Evaluate removing `caelestia-shell` flake input from `flake.nix` if no other host uses it
