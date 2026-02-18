{
  lib,
  config,
  ...
}:
let
  cfg = config.user.terminal.shell.blesh;
  inherit (lib) mkIf;

  # Fish-like color scheme for ble.sh (based on fish default.nix colors)
  # Fish br* = bright; ble.sh: lime=brgreen, blue=brblue, magenta, cyan, yellow, red, gray=brblack
  blercContent = ''
    # ble.sh face colors — aligned with fish (modules/home/user/terminal/shell/fish/default.nix)
    # Syntax highlighting
    ble-face syntax_default='none'
    ble-face syntax_command='fg=lime'
    ble-face syntax_comment='fg=magenta'
    ble-face syntax_quoted='fg=yellow'
    ble-face syntax_quotation='fg=yellow,bold'
    ble-face syntax_escape='fg=cyan'
    ble-face syntax_error='fg=red'
    ble-face syntax_delimiter='fg=yellow'
    ble-face syntax_param_expansion='fg=blue'
    ble-face syntax_history_expansion='bold'
    ble-face syntax_varname='fg=blue'
    # Command highlighting
    ble-face command_builtin='fg=green'
    ble-face command_builtin_dot='fg=green,bold'
    ble-face command_file='fg=lime'
    ble-face command_directory='fg=green,underline'
    ble-face command_alias='fg=teal'
    ble-face command_function='fg=blue'
    ble-face command_keyword='fg=cyan'
    ble-face argument_option='fg=cyan'
    # Inactive / autosuggestion (fish_color_autosuggestion brblack)
    ble-face disabled='fg=gray'
    # Selection (fish_color_selection white bold background=brblack)
    ble-face region='fg=white,bold,bg=gray'
    ble-face region_match='fg=yellow,bg=gray'
    ble-face region_insert='fg=white,bold,bg=gray'
    # Filenames (fish_color_valid_path underline)
    ble-face filename_directory='underline,fg=green'
    ble-face filename_executable='underline,fg=lime'
    ble-face filename_other='underline'
    ble-face filename_link='underline,fg=cyan'
    # Completion menu (fish_pager colors)
    ble-face auto_complete='fg=gray'
  '';
in
{
  options.user.terminal.shell.blesh = {
    enable = lib.mkEnableOption "ble.sh config (~/.blerc) with fish-like colors";
  };

  config = mkIf cfg.enable {
    home.file.".blerc".text = blercContent;
  };
}
