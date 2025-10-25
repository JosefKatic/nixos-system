{
  lib,
  pkgs,
  config,
  ...
}: let
  cfg = config.user.desktop.programs.productivity.zathura;
in {
  options.user.desktop.programs.productivity.zathura = {
    enable = lib.mkEnableOption "Enable Zathura PDF viewer";
  };

  config = lib.mkIf cfg.enable {
    programs.zathura = {
      enable = true;
      options = {
        recolor-lightcolor = "rgba(0,0,0,0)";
        default-bg = "rgba(0,0,0,0.7)";

        font = "Inter 12";
        selection-notification = true;

        selection-clipboard = "clipboard";
        adjust-open = "best-fit";
        pages-per-row = "1";
        scroll-page-aware = "true";
        scroll-full-overlap = "0.01";
        scroll-step = "100";
        zoom-min = "10";
      };

      extraConfig =
        "include catppuccin-"
        + (
          if config.programs.matugen.variant == "light"
          then "latte"
          else "mocha"
        );
    };

    xdg.configFile = {
      "zathura/catppuccin-latte".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/zathura/main/src/catppuccin-latte";
        hash = "sha256-h1USn+8HvCJuVlpeVQyzSniv56R/QgWyhhRjNm9bCfY=";
      };
      "zathura/catppuccin-mocha".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/zathura/main/src/catppuccin-mocha";
        hash = "sha256-POxMpm77Pd0qywy/jYzZBXF/uAKHSQ0hwtXD4wl8S2Q=";
      };
    };
  };
}
