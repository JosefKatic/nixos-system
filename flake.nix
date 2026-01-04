{
  description = "Flake with modules for joka00.dev";

  nixConfig = {
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  inputs = {
    # Flake
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    systems.url = "github:nix-systems/default-linux";

    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    hardware.url = "github:nixos/nixos-hardware";
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nh = {
      url = "github:viperML/nh";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hm = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";

    treefmt-nix.url = "github:numtide/treefmt-nix";

    lanzaboote.url = "github:nix-community/lanzaboote";

    impermanence.url = "github:nix-community/impermanence";

    nix-index-db = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixcord.url = "github:kaylorben/nixcord";

    nix-gaming.url = "github:fufexan/nix-gaming";

    matugen = {
      url = "github:InioX/Matugen";
    };

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NUR
    nur.url = "github:nix-community/NUR";

    web.url = "github:JosefKatic/web";

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    crowdsec-module-rework.url = "github:TornaxO7/nixpkgs/crowdsec";

    # Server
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-configurator-api = {
      url = "github:JosefKatic/nix-configurator-api";
    };
    nix-configurator-web = {
      url = "github:JosefKatic/nix-configurator-web";
    };

  };
  outputs =
    {
      nixpkgs,
      flake-parts,
      nur,
      treefmt-nix,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      perSystem =
        { system, pkgs, ... }:
        let
          treefmtEval = treefmt-nix.lib.evalModule pkgs ./treefmt.nix;
        in
        {
          formatter = treefmtEval.config.build.wrapper;
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = [
              inputs.self.overlays.joka00-modules
              nur.overlays.default
            ];
          };
        };
      imports = [
        ./.hydra
        ./shell.nix
        ./packages
        ./overlays
        ./modules
        ./pre-commit-hooks.nix
        ./config
        treefmt-nix.flakeModule
      ];
    };
}
