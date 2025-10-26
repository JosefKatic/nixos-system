{
  inputs,
  config,
  lib,
  ...
}:
{
  imports = [
    ./defaultBrowser.nix
    ./brave
    ./chromium
    ./firefox
    ./zen
  ];
}
