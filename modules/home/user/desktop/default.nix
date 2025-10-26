{
  inputs,
  ...
}:
{
  imports = [
    ./programs
    ./services
    ./monitors.nix
    ./gtk.nix
    ./wayland
    ./qt.nix
  ];
}
