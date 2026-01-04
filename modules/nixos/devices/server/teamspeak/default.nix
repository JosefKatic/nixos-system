{
  config,
  lib,
  ...
}:
let
  cfg = config.device.server;
in
{
  imports = [ ./modules.nix ];

  options.device.server.teamspeak.enable = lib.mkEnableOption "Enable teamspeak server";

  config = lib.mkIf cfg.teamspeak.enable {
    services = {
      teamspeak6 = {
        enable = true;
        openFirewall = true;
        defaultVoicePort = 29102;
        fileTransferPort = 39102;
      };
    };

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist".directories = [
        "/var/lib/teamspeak6-server"
        "/var/log/teamspeak6-server"
      ];
    };
  };
}
