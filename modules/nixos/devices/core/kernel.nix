{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.device.core;
in
{
  options = {
    device.core.kernel = lib.mkOption {
      default = if config.device.type == "server" then "default" else "zen";
      type = lib.types.str;
    };
  };

  config = {
    boot = {
      kernelPackages =
        if config.device.core.kernel == "default" then
          pkgs.linuxPackages
        else
          pkgs."linuxPackages_${config.device.core.kernel}";
      extraModulePackages = lib.mkIf (config.device.type != "server") (
        with config.boot.kernelPackages; [ ddcci-driver ]
      );
      extraModprobeConfig = lib.mkIf config.device.virtualized "options kvm nested=1";
    };
    services.fwupd.enable = true;
  };
}
