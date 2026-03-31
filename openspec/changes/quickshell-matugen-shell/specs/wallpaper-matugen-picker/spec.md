## ADDED Requirements

### Requirement: Wallpaper picker UI is available in quickshell
The quickshell shell SHALL include a wallpaper picker component that lists image files from a configured directory.

#### Scenario: Picker shows available wallpapers
- **WHEN** the user opens the wallpaper picker (via keybind or shell trigger)
- **THEN** a grid or list of images from `quickshell.wallpaperDir` SHALL be displayed

#### Scenario: wallpaperDir defaults to ~/Pictures/Wallpapers
- **WHEN** `quickshell.wallpaperDir` is not set in the home-manager config
- **THEN** the picker SHALL default to `~/Pictures/Wallpapers`

### Requirement: Selecting a wallpaper triggers matugen and live reload
On wallpaper selection, the system SHALL: set the wallpaper, run `matugen image <path>`, and signal quickshell to reload its color palette — without requiring a rebuild.

#### Scenario: Wallpaper change updates colors live
- **WHEN** the user selects a wallpaper in the picker
- **THEN** the wallpaper is applied to the compositor (swaybg or equivalent)
- **THEN** `matugen image <wallpaper-path>` runs and writes color tokens to `~/.config/matugen/`
- **THEN** quickshell hot-reloads its colors without restarting

#### Scenario: Color files are written to the runtime dir
- **WHEN** matugen runs after wallpaper selection
- **THEN** color token files SHALL appear in `~/.config/quickshell/colors/` (or `~/.config/matugen/`)
- **THEN** the files SHALL be writable (not store symlinks)

### Requirement: A default wallpaper and color palette exist on first boot
On first login (before the user has selected a wallpaper), the system SHALL apply a default wallpaper and generate colors from it.

#### Scenario: First-time activation generates colors
- **WHEN** `home-manager switch` is run and no color file exists yet
- **THEN** the activation script runs matugen with a bundled default wallpaper
- **THEN** quickshell starts with a valid color palette
