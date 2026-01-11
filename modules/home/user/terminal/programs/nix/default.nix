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
    nixfmt-tree
    deadnix
    statix
  ];
}
