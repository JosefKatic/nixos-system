{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.wayland.hyprland;
in
{
  options.user.desktop.wayland.hyprland.enable = lib.mkEnableOption "Enable Hyprland";
  # enable hyprland

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      systemd = {
        enable = false;
      };
    };
    user.desktop.wayland.hyprland.services.hyprsunset.enable = true;
  };
}
