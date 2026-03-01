{ config, lib, ... }:
{
  options.user.desktop.wayland.shell = {
    enable = lib.mkEnableOption "Enable Wayland desktop environment";
  };
  config = lib.mkIf config.user.desktop.wayland.shell.enable {
    programs.caelestia = {
      enable = true;
      systemd = {
        enable = true; # if you prefer starting from your compositor
        target = "graphical-session.target";
        environment = [ ];
      };
      cli = {
        enable = true; # Also add caelestia-cli to path
        settings = {
          theme.enableGtk = true;
        };
      };
    };
  };
}
