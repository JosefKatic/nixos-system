{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.user.desktop.wayland.hyprland.plugins.hyprexpo;
in
{
  options.user.desktop.wayland.hyprland.plugins.hyprexpo = {
    enable = lib.mkEnableOption "Enable Hyprexpo";
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      plugins = [
        pkgs.hyprlandPlugins.hyprexpo
      ];
      settings = {
        bind = [
          "$mod, S, hyprexpo:expo, toggle"
        ];
        plugin = {
          hyprexpo = {
            columns = 5;
            gap_size = 5;
            bg_col = "rgb($background)";
            workspace_method = "center current"; # [center/first] [workspace] e.g. first 1 or center m+1

            gesture_distance = 300; # how far is the "max" for the gesture
          };
        };
      };
    };
  };
}
