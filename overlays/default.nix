{
  inputs,
  lib,
  ...
}:
{
  flake.overlays = {
    joka00-modules = lib.composeManyExtensions [
      inputs.nix-minecraft.overlay
    ];
    flake-inputs = final: _: {
      inputs = builtins.mapAttrs (
        _: flake:
        let
          legacyPackages = (flake.legacyPackages or { }).${final.stdenv.hostPlatform.system} or { };
          packages = (flake.packages or { }).${final.stdenv.hostPlatform.system} or { };
        in
        legacyPackages // packages
      ) inputs;
    };
  };
}
