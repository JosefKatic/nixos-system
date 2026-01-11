{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in
{
  options.device.server.homelab = {
    matter = {
      enable = mkEnableOption "Matter";
    };
  };

  config = mkIf cfg.matter.enable {
    networking.firewall.allowedTCPPorts = [ 5580 ];
    services.matter-server = {
      enable = true;
    };
    environment.persistence = mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [ "/var/lib/private/matter-server" ];
      };
    };
  };
}
