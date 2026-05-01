{
  lib,
  config,
  ...
}:
let
  cfg = config.user.desktop.programs.emulators.kitty;
  caelestiaShell = config.user.desktop.wayland.shell.enable;
  caelestiaColorsPath = "${config.home.homeDirectory}/.local/state/caelestia/theme/colors.conf";
in
{
  options.user.desktop.programs.emulators.kitty = {
    enable = lib.mkEnableOption "Enable Kitty";
  };
  config = lib.mkIf cfg.enable {
    xdg.configFile = lib.mkIf caelestiaShell {
      "caelestia/templates/colors.conf".source = ./caelestia-colors.template;
    };

    programs.kitty = {
      enable = true;
      font = {
        size = 12;
        name = "JetBrains Mono";
      };

      # With Caelestia: user template ~/.config/caelestia/templates/colors.conf is
      # rendered to ~/.local/state/caelestia/theme/colors.conf on each scheme
      # change, so new Kitty windows match the current palette (OSC-only theming
      # does not persist for new processes). Otherwise matugen-style path.
      extraConfig =
        if caelestiaShell then "include ${caelestiaColorsPath}" else "include ~/.config/kitty/colors.conf";

      settings = {
        scrollback_lines = 10000;
        window_padding_width = 15;
        placement_strategy = "center";

        allow_remote_control = "yes";
        listen_on = "unix:/tmp/kitty-matugen";
        enable_audio_bell = "no";
        visual_bell_duration = "0.1";

        copy_on_select = "clipboard";
      };
    };

    # Before the first scheme apply, include must resolve; placeholder is replaced
    # when caelestia-cli runs apply_user_templates.
    home.activation.ensureCaelestiaKittyColors = lib.mkIf caelestiaShell (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p "${config.home.homeDirectory}/.local/state/caelestia/theme"
        _f=${lib.escapeShellArg caelestiaColorsPath}
        if [ ! -f "$_f" ]; then
          printf '%s\n' \
            '# Placeholder until caelestia applies a scheme' \
            'foreground #c0caf5' \
            'background #1a1b26' \
            > "$_f"
        fi
      ''
    );
  };
}
