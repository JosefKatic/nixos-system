{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.device.server.services.homelab;
in
{
  options.device.server.services.homelab = {
    matter = {
      enable = mkEnableOption "Matter";
    };
  };

  config = mkIf cfg.matter.enable {
    networking.firewall.allowedTCPPorts = [ 5580 ];
    services.matter-server = {
      enable = true;
    };
  };
}
