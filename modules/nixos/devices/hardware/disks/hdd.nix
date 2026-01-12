{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.device.hardware;
in
{
  options.device.hardware.disks.hdd = {
    enable = lib.mkEnableOption "Enable HDD modules";
  };

  config = lib.mkIf cfg.disks.hdd.enable {
    # services.hdapsd.enable = lib.mkDefault true;
    boot.kernelModules = [ "hdapsd" ];
    services.udev.packages = [ pkgs.inputs.self.hdapsd ];
    systemd.packages = [ pkgs.inputs.self.hdapsd ];
  };
}
