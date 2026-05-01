{
  config,
  lib,
  pkgs,
  ...
}:
let
  caelestiaShell = config.user.desktop.wayland.shell.enable;
  # Caelestia CLI `apply_qt`: KDE-style colors at XDG_CONFIG_HOME/qtengine/caelestia.colors
  caelestiaColorScheme = "${config.xdg.configHome}/qtengine/caelestia.colors";

  qtctAppearance = {
    color_scheme_path = caelestiaColorScheme;
    icon_theme = "Papirus-Dark";
    standard_dialogs = "xdgdesktopportal";
    # Matches Caelestia's qtengine.json template (`style: "Darkly"`).
    style = "darkly";
  };
in
{
  config = {
    qt = {
      enable = true;
    }
    // lib.optionalAttrs caelestiaShell {
      platformTheme.name = "qt6ct";
      style = {
        name = "darkly";
        package = [
          pkgs.darkly-qt5
          pkgs.darkly
        ];
      };
      qt6ctSettings = {
        Appearance = qtctAppearance;
      };
      qt5ctSettings = {
        Appearance = qtctAppearance;
      };
    };

    # PrismLauncher and other Qt 6 apps ignore `QT_QPA_PLATFORMTHEME=qt5ct` (what HM sets for
    # `platformTheme = qtct`). Without this, Qt 6 falls back to the default platform theme and
    # never loads qt6ct — so `~/.config/qt6ct/qt6ct.conf` (and Caelestia colors) are unused.
    home.sessionVariables = lib.mkIf caelestiaShell {
      QT_QPA_PLATFORMTHEME_QT6 = lib.mkDefault "qt6ct";
    };

    systemd.user.sessionVariables = lib.mkIf caelestiaShell {
      QT_QPA_PLATFORMTHEME_QT6 = lib.mkDefault "qt6ct";
    };
  };
}
