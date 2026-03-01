{ config, lib, ... }:
let
  cfg = config.device.server.services.netbird;
in
{
  options.device.server.services.netbird.server = {
    enable = lib.mkEnableOption "Enable Netbird server";
  };

  config = lib.mkIf cfg.server.enable {
    services.netbird.server = {
      enable = true;
      enableNginx = false; # We use Traefik for reverse proxy
      domain = "vpn.joka00.dev";
    };
    environment.persistence."/persist".directories = [
      "/var/lib/netbird-mgmt"
      "/var/lib/netbird-signal"
      "/var/lib/private/netbird-relay"
    ];
  };
  imports = [
    ./client.nix
    ./dashboard.nix
    ./management.nix
    ./relay.nix
    ./signal.nix
  ];
}
