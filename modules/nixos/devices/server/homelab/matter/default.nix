{
  self,
  config,
  lib,
  ...
}: let
  inherit (lib) types mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in {
  options.device.server.homelab = {
    matter = {
      enable = mkEnableOption "Matter";
    };
  };

  config = mkIf cfg.mosquitto.enable {
    services.matter-server = {
      enable = true;
      openFirewall = true;
    };
    environment.persistence = mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = ["/var/lib/matter-server"];
      };
    };
  };
}
