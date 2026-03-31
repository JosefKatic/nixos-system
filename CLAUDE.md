# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a modular NixOS system configuration using Nix Flakes and flake-parts. It manages 5 hosts (1 desktop: `alcedo`, 4 servers: `falco`, `hirundo`, `regulus`, `strix`) with home-manager for user environments, SOPS+age for secrets, and Hydra for CI.

## Common Commands

```bash
# Format all Nix files (also runs as pre-commit hook)
nix fmt

# Check the flake for errors
nix flake check

# Update all flake inputs
nix flake update

# Build a specific host system
nix build .#nixosConfigurations.alcedo.config.system.build.toplevel

# Deploy to current host using nh (preferred)
nh os switch .

# Deploy to a specific host using nh
nh os switch . -- --flake .#alcedo

# Deploy home-manager config using nh
nh home switch .

# Deploy to current host (alternative, requires root)
sudo nixos-rebuild switch --flake .#alcedo

# Deploy home-manager config (alternative)
home-manager switch --flake .#joka@alcedo

# Enter dev shell (also automatic via direnv)
nix develop
```

## Repository Architecture

### Entry Point

`flake.nix` defines all inputs and uses `flake-parts` to compose outputs from:
- `./.hydra` — Hydra CI job definitions
- `./shell.nix` — Dev shell
- `./packages` — Custom packages
- `./overlays` — nixpkgs overlays
- `./modules` — Reusable NixOS and home-manager modules
- `./pre-commit-hooks.nix` — Git hooks (nixfmt, prettier)
- `./config` — Per-host and per-user configurations

nixpkgs is patched via `nixpkgs-patcher` before being used everywhere.

### Config Layer (`config/`)

Per-host and per-user configurations. Each host/user has three files:
- `default.nix` — imports static and generated
- `static.nix` — hand-written settings (device type, CPU/GPU type, storage config)
- `generated.nix` — hardware-scan output

NixOS configs live in `config/nixos/<host>/`, home-manager configs in `config/home/<host>/<user>/`.

### Modules Layer (`modules/`)

Reusable modules split into two trees:

**`modules/nixos/devices/`** — NixOS modules:
- `boot/` — UEFI (lanzaboote/secureboot), legacy, quiet boot
- `core/` — Networking, security, audio, locale, SSH, storage, power, nix settings
- `desktop/` — Wayland, Hyprland, Niri, display managers
- `hardware/` — CPU (Intel/AMD), GPU (Nvidia/AMD/Intel), disks, Bluetooth, peripherals
- `server/` — Auth (Authelia, Pocket-ID), databases, reverse proxy, Cloudflared, Minecraft, Hydra
- `users/` — User management

**`modules/home/user/`** — Home-manager modules:
- `terminal/` — Shell configs, CLI programs
- `desktop/` — GUI apps, Wayland-specific services
- `services/` — Media, system services
- `theme/` — Matugen-based theming, nix-colors

### Secrets (`secrets/`)

Encrypted with SOPS+age. Rules defined in `.sops.yaml` — each host has its own age key derived from its SSH host key. To add a new secret: create the file, add the path pattern to `.sops.yaml`, then `sops encrypt`.

### Key Inputs

- **nixpkgs**: unstable channel, patched via nixpkgs-patcher
- **hm**: home-manager
- **sops-nix**: secrets management
- **lanzaboote**: Secure Boot (used on alcedo)
- **impermanence**: Ephemeral root filesystem
- **nix-gaming**, **nixcord**, **zen-browser**: Desktop extras
- **nix-minecraft**: Minecraft server management
- **matugen**: Material You color scheme generation
- **caelestia-shell / caelestia-cli**: Shell UI framework
