## ADDED Requirements

### Requirement: Custom quickshell config is managed in-repo
The system SHALL maintain quickshell QML sources under `modules/home/user/desktop/wayland/quickshell/config/` in this repository. Home-manager SHALL install these as read-only store symlinks under `~/.config/quickshell/`.

#### Scenario: QML sources are installed on home-manager switch
- **WHEN** `nh home switch .` is run on alcedo or hirundo
- **THEN** `~/.config/quickshell/shell.qml` (and related QML files) SHALL be symlinks pointing into the Nix store

#### Scenario: Module is enabled per-host
- **WHEN** `modules/home/user/desktop/wayland/quickshell` is imported in a host's home config
- **THEN** quickshell package is installed and QML config is linked

### Requirement: Quickshell shell provides core desktop shell components
The quickshell shell SHALL provide at minimum: a status bar, app launcher trigger, and notification area.

#### Scenario: Shell starts on login
- **WHEN** the user logs into a Wayland session on alcedo or hirundo
- **THEN** the quickshell process starts and the bar is visible

### Requirement: caelestia-shell is replaced
The system SHALL NOT load caelestia-shell after this change is applied on alcedo and hirundo.

#### Scenario: caelestia-shell module is disabled
- **WHEN** the quickshell module is enabled in a host config
- **THEN** caelestia-shell MUST NOT be started or managed by home-manager for that host
