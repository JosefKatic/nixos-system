{
  config,
  lib,
  ...
}:
let
  cfg = config.device.core.shells;
in
{
  options.device.core.shells.bash = {
    enable = lib.mkEnableOption "Enable bash shell";
  };

  config = lib.mkIf cfg.bash.enable {
    programs.bash = {
      enable = true;
      blesh.enable = true;
    };
  };
}
