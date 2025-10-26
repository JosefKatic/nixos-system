{ pkgs, ... }:
{
  imports = [
    ./static.nix
    ./generated.nix
  ];
  home.packages = [
    pkgs.trezor-suite
  ];
}
