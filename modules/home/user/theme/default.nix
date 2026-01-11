{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.theme.colorscheme;
  inherit (lib) types mkOption;

  hexColor = types.strMatching "#([0-9a-fA-F]{3}){1,2}";
in
{
  options.theme = {
    colorscheme = {
      source = mkOption {
        type = types.either types.path hexColor;
        default = if config.theme.wallpaper != null then config.theme.wallpaper else "#2B3975";
      };
      mode = mkOption {
        type = types.enum [
          "dark"
          "light"
        ];
        default = "dark";
      };
      type = mkOption {
        type = types.str;
        default = "rainbow";
      };

      generatedDrv = mkOption {
        type = types.package;
        default = pkgs.inputs.self.generateColorscheme (cfg.source.name or "default") cfg.source;
      };
      rawColorscheme = mkOption {
        type = types.attrs;
        default = cfg.generatedDrv.imported.${cfg.type};
      };

      colors = mkOption {
        readOnly = true;
        type = types.attrsOf (
          types.submodule {
            options = {
              dark = mkOption {
                type = hexColor;
              };
              default = mkOption {
                type = hexColor;
              };
              light = mkOption {
                type = hexColor;
              };
            };
          }
        );
        default = cfg.rawColorscheme.colors;
      };
    };
    wallpaper = lib.mkOption {
      description = ''
        Location of the wallpaper to use throughout the system.
      '';
      default = pkgs.inputs.self.wallpapers.astronaut-minimalism;
      type = types.path;
      example = lib.literalExample "./wallpaper.png";
    };
  };
}
