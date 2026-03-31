## ADDED Requirements

### Requirement: Theme output dirs are not managed by home-manager
The directories `~/.config/matugen/` and `~/.config/quickshell/colors/` SHALL NOT be declared in `home.file` or `xdg.configFile`. Home-manager MUST NOT symlink or own these paths.

#### Scenario: Dirs exist after switch but are writable
- **WHEN** `nh home switch .` runs on alcedo or hirundo
- **THEN** `~/.config/matugen/` and `~/.config/quickshell/colors/` SHALL exist
- **THEN** both dirs SHALL be writable by the user (not read-only store paths)

#### Scenario: HM switch does not clobber existing color files
- **WHEN** matugen has previously written color files and `nh home switch .` runs again
- **THEN** color files SHALL remain intact after the switch

### Requirement: Module activation creates runtime dirs if absent
The quickshell home-manager module SHALL create `~/.config/matugen/` and `~/.config/quickshell/colors/` via a `home.activation` script if they do not exist.

#### Scenario: Fresh install creates dirs
- **WHEN** the quickshell module is enabled and `home-manager switch` runs for the first time
- **THEN** both runtime dirs SHALL be created with user ownership

### Requirement: Impermanence hosts persist theme dirs
When `quickshell.persist = true` is set, the module SHALL add `~/.config/matugen` and `~/.config/quickshell/colors` to `home.persistence`.

#### Scenario: Persist option adds paths to home.persistence
- **WHEN** `quickshell.persist = true` is set on a host using impermanence
- **THEN** color and matugen dirs SHALL survive reboots

#### Scenario: Module warns when impermanence is detected but persist is unset
- **WHEN** the impermanence home-manager module is active on the host AND `quickshell.persist` is not set to `true`
- **THEN** a NixOS evaluation warning SHALL be emitted advising the user to set `quickshell.persist = true`
