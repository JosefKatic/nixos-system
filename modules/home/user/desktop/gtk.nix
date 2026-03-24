{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.theme.colorscheme) colors;
  hash = builtins.hashString "md5" (builtins.toJSON config.theme.colorscheme.type);
  rendersvg = pkgs.runCommand "rendersvg" { } ''
    mkdir -p $out/bin
    ln -s ${pkgs.resvg}/bin/resvg $out/bin/rendersvg
  '';
in
{
  options.user.desktop.gtk = {
    enable = lib.mkEnableOption "Enable GTK settings";
  };
  config = lib.mkIf config.user.desktop.gtk.enable {
    home.pointerCursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 16;
      gtk.enable = true;
      x11.enable = true;
    };

    gtk = {
      enable = true;
    };

    services.xsettingsd = {
      enable = true;
      # settings = {
      # "Net/ThemeName" = "${config.gtk.theme.name}";
      # "Net/IconThemeName" = "${config.gtk.iconTheme.name}";
      # };
    };

    home.packages = with pkgs; [
      libdbusmenu-gtk3
      sassc
    ];

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
