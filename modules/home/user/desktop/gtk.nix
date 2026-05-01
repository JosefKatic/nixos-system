{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.user.desktop.gtk;

  # Matches caelestia-cli `apply_gtk`: dconf gtk-theme `adw-gtk3-dark`, icon Papirus-{Dark,Light}
  caelestiaGtk = {
    theme = {
      package = pkgs.adw-gtk3;
      name = "adw-gtk3-dark";
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
  };
in
{
  options.user.desktop.gtk = {
    enable = lib.mkEnableOption "Enable GTK settings";

    caelestiaRuntimeTheming = lib.mkOption {
      type = lib.types.bool;
      default = config.user.desktop.wayland.shell.enable;
      description = ''
        When true, Home Manager does not install store-backed GTK 2/3/4 config
        (e.g. ''${XDG_CONFIG_HOME}/gtk-3.0/settings.ini), so Caelestia CLI can
        write ''${XDG_CONFIG_HOME}/gtk-3.0/gtk.css, gtk-4.0/gtk.css, and dconf
        keys when the scheme changes. Theme packages are still installed.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
      gtk4.theme = null;
    }
    // lib.optionalAttrs cfg.caelestiaRuntimeTheming {
      gtk2.enable = false;
      gtk3.enable = false;
      gtk4.enable = false;
      theme = lib.mkDefault caelestiaGtk.theme;
      iconTheme = lib.mkDefault caelestiaGtk.iconTheme;
    };

    # xsettingsd only sees build-time strings; Caelestia switches light/dark via dconf instead.
    services.xsettingsd =
      lib.mkIf (!cfg.caelestiaRuntimeTheming && config.gtk.theme != null && config.gtk.iconTheme != null)
        {
          enable = true;
          settings = {
            "Net/ThemeName" = config.gtk.theme.name;
            "Net/IconThemeName" = config.gtk.iconTheme.name;
          };
        };

    home.packages =
      (with pkgs; [
        libdbusmenu-gtk3
        sassc
      ])
      ++ lib.optionals cfg.caelestiaRuntimeTheming [
        caelestiaGtk.theme.package
        caelestiaGtk.iconTheme.package
      ];

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
