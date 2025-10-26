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
    nixfmt-rfc-style
    nixfmt-tree
    deadnix
    statix
  ];
}
