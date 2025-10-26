{
  config,
  pkgs,
  self,
  lib,
  ...
}:
# nix tooling
{
  home.packages = with pkgs; [
    nixd
    nixfmt
    deadnix
    statix
  ];
}
