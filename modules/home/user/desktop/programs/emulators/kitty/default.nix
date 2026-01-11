{
  config,
  lib,
  ...
}:
let
  inherit (config.theme.colorscheme) colors mode;
  cfg = config.user.desktop.programs.emulators.kitty;
in
{
  options.user.desktop.programs.emulators.kitty = {
    enable = lib.mkEnableOption "Enable Kitty";
  };
  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        size = 12;
        name = "JetBrains Mono";
      };

      settings = {
        scrollback_lines = 10000;
        window_padding_width = 15;
        placement_strategy = "center";

        allow_remote_control = "yes";
        enable_audio_bell = "no";
        visual_bell_duration = "0.1";

        copy_on_select = "clipboard";

        foreground = "${colors.on_surface.default}";
        background = "${colors.surface.default}";
        selection_background = "${colors.on_surface.default}";
        selection_foreground = "${colors.surface.default}";
        url_color = "${colors.on_surface_variant.default}";
        cursor = "${colors.on_surface.default}";
        active_border_color = "${colors.outline.default}";
        inactive_border_color = "${colors.surface_bright.default}";
        active_tab_background = "${colors.surface.default}";
        active_tab_foreground = "${colors.on_surface.default}";
        inactive_tab_background = "${colors.surface_bright.default}";
        inactive_tab_foreground = "${colors.on_surface_variant.default}";
        tab_bar_background = "${colors.surface_bright.default}";
        color0 = "${colors.surface.default}";
        color1 = "${colors.red_source.default}";
        color2 = "${colors.green_source.default}";
        color3 = "${colors.yellow_source.default}";
        color4 = "${colors.blue_source.default}";
        color5 = "${colors.magenta_source.default}";
        color6 = "${colors.cyan_source.default}";
        color7 = "${colors.on_surface.default}";
        color8 = "${colors.outline.default}";
        color9 = "${colors.red_source.default}";
        color10 = "${colors.green_source.default}";
        color11 = "${colors.yellow_source.default}";
        color12 = "${colors.blue_source.default}";
        color13 = "${colors.magenta_source.default}";
        color14 = "${colors.cyan_source.default}";
        color15 = "${colors.surface_dim.default}";
        color16 = "${colors.orange_source.default}";
        color17 = "${colors.error.default}";
        color18 = "${colors.surface_bright.default}";
        color19 = "${colors.surface_container.default}";
        color20 = "${colors.on_surface_variant.default}";
        color21 = "${colors.inverse_surface.default}";
      };
    };
  };
}
