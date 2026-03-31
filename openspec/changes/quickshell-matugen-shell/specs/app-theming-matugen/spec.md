## ADDED Requirements

### Requirement: GTK4 colors are applied from matugen output at runtime
The system SHALL configure GTK4 to read a runtime-generated `gtk.css` file written by matugen, instead of baking colors into the Nix store at build time. The file `~/.config/gtk-4.0/gtk.css` SHALL be unmanaged by home-manager and writable by matugen.

#### Scenario: Wallpaper change updates GTK4 colors in running windows
- **WHEN** the user selects a wallpaper in the quickshell picker and matugen runs
- **THEN** `~/.config/gtk-4.0/gtk.css` SHALL be written with the new Material You palette
- **THEN** a theme reload signal SHALL be sent to the GTK4 settings daemon (via `gsettings set org.gnome.desktop.interface gtk-theme` toggle or equivalent) so that already-open GTK4 windows re-read and apply the new CSS without restart

#### Scenario: GTK4 css dir is not owned by home-manager
- **WHEN** `nh home switch .` runs
- **THEN** `~/.config/gtk-4.0/gtk.css` SHALL NOT be overwritten or removed by home-manager
- **THEN** `~/.config/gtk-4.0/gtk.css` SHALL remain writable by the user

#### Scenario: First boot generates GTK4 colors
- **WHEN** home-manager activates for the first time and no `gtk.css` exists
- **THEN** the activation script SHALL run matugen with the default wallpaper to produce `~/.config/gtk-4.0/gtk.css`

### Requirement: Qt color scheme is applied from matugen output at runtime
The system SHALL configure qt5ct and qt6ct to use a color scheme file written by matugen at `~/.config/qt5ct/colors/matugen.conf` and `~/.config/qt6ct/colors/matugen.conf`. These files SHALL be unmanaged by home-manager.

#### Scenario: Wallpaper change updates Qt colors in running windows
- **WHEN** matugen runs after a wallpaper selection
- **THEN** qt5ct and qt6ct color scheme files SHALL be updated with the new palette
- **THEN** a D-Bus `org.freedesktop.appearance` color-scheme change signal or a `QApplication::setPalette` reload SHALL be triggered so that running Qt windows re-apply the palette without restart

#### Scenario: qt5ct/qt6ct config points to matugen scheme
- **WHEN** home-manager activates
- **THEN** `~/.config/qt5ct/qt5ct.conf` SHALL declare `color_scheme_path=~/.config/qt5ct/colors/matugen.conf`
- **THEN** the color scheme files themselves SHALL NOT be store-managed (writable by matugen)

### Requirement: Kitty terminal uses a runtime-included color file
The system SHALL configure kitty to `include` a runtime color file at `~/.config/kitty/colors.conf`, written by matugen, rather than baking color values into the store-managed kitty config. All other kitty settings remain home-manager managed.

#### Scenario: Kitty loads runtime colors on start
- **WHEN** kitty starts after a matugen run
- **THEN** kitty SHALL read colors from `~/.config/kitty/colors.conf`
- **THEN** the terminal colors SHALL match the current Material You palette

#### Scenario: Kitty colors update without full restart
- **WHEN** matugen writes a new `~/.config/kitty/colors.conf`
- **THEN** running kitty instances SHALL reload colors via `kitten themes --reload-in=all` or equivalent kitty remote control

#### Scenario: colors.conf is not managed by home-manager
- **WHEN** `nh home switch .` runs
- **THEN** `~/.config/kitty/colors.conf` SHALL NOT be overwritten or declared in `xdg.configFile`

### Requirement: Existing build-time color bindings are removed from affected modules
The build-time color bindings from `config.theme.colorscheme.colors` SHALL be removed from kitty settings and GTK module for any values that are now covered by runtime matugen output. The `theme.colorscheme` module remains for other consumers but SHALL NOT be the source of truth for runtime-themed app colors.

#### Scenario: Kitty module no longer references theme.colorscheme.colors for palette
- **WHEN** reading `modules/home/user/desktop/programs/emulators/kitty/default.nix`
- **THEN** foreground/background/cursor color settings SHALL NOT be set via `config.theme.colorscheme.colors`
- **THEN** an `include ~/.config/kitty/colors.conf` directive SHALL be present in the kitty config

#### Scenario: GTK module no longer sets colors from theme.colorscheme
- **WHEN** reading `modules/home/user/desktop/gtk.nix`
- **THEN** no color values from `config.theme.colorscheme.colors` SHALL be written into store-managed GTK config files for GTK4

### Requirement: Impermanence hosts persist app theme dirs
When `quickshell.persist = true`, the matugen output dirs for app theming SHALL also be persisted: `~/.config/gtk-4.0/`, `~/.config/qt5ct/colors/`, `~/.config/qt6ct/colors/`, `~/.config/kitty/colors.conf`.

#### Scenario: App theme files survive reboot on impermanence hosts
- **WHEN** `quickshell.persist = true` is set and the host uses impermanence
- **THEN** all runtime color files SHALL be listed in `home.persistence` and survive reboots
