{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.wayland.hyprland.services.hyprpaper;
in
{
  options.user.desktop.wayland.hyprland.services.hyprpaper.enable =
    lib.mkEnableOption "Enable Hyprpaper";

  config = lib.mkIf cfg.enable {
    services.hyprpaper = {
      enable = true;
      package = pkgs.hyprpaper;
      settings = {
        splash = false;
        wallpaper = [
          {
            monitor = "";
            fit_mode = "cover";
            path = config.theme.wallpaper;
          }
        ];
      };
    };
  };
}
