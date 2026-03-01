{ config, lib, ... }:
let
  cfg = config.device.server.databases.mongodb;
in
{
  options.device.server.databases.mongodb = {
    enable = lib.mkEnableOption "Enable MongoDB database";
  };

  config = lib.mkIf cfg.enable {
    services.mongodb = {
      enable = true;
    };

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist".directories = [
        "/var/lib/mongodb"
      ];
    };
  };
}
