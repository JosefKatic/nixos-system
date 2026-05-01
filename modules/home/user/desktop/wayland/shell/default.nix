{
  config,
  lib,
  pkgs,
  ...
}:
let
  logoFile = pkgs.fetchurl {
    url = "https://joka00.dev/assets/logo__dark.svg";
    sha256 = "1xd5hfxlh0m5687mfxndyv18a2k6aq7njna4n5smn7f7ynal1i28";
  };
in
{
  options.user.desktop.wayland.shell = {
    enable = lib.mkEnableOption "Enable Wayland desktop environment";
  };
  config = lib.mkIf config.user.desktop.wayland.shell.enable {
    programs.caelestia = {
      enable = true;
      systemd = {
        enable = false;
      };
      settings = {
        general = {
          logo = logoFile;
          apps = {
            audio = [ "pwvucontrol" ];
            browsers = [ "zen" ];
            terminal = [ "kitty" ];
            explorer = [
              "thunar"
              "ranger"
            ];
          };
        };
        bar = {
          status = {
            showAudio = true;
            showBattery = true;
          };
          tray = {
            compact = true;
          };
          workspaces.label = "";
        };
        osd.enableMicrophone = true;
        services = {
          useFahrenheit = false;
          useTwelveHourClock = true;
        };
        utilities.toasts.nowPlaying = true;
      };

      cli = {
        enable = true; # Also add caelestia-cli to path
        settings = {
          theme.enableGtk = true;
          # Writes ~/.config/qtengine/caelestia.colors (+ config.json) from Matugen-driven scheme.
          theme.enableQt = true;
        };
      };
    };
  };
}
