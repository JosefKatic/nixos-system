# Netbird relay server (replaces Coturn for NAT traversal).
# Add to secrets/services/netbird/secrets.yaml: relay-auth-secret: "<value>"
# Generate with: openssl rand -base64 32
{
  config,
  lib,
  self,
  pkgs,
  ...
}:
let
  netbirdCfg = config.services.netbird.server;
  # Default relay port from upstream module is 33080
  relayPort = "33080";
  cfg = config.device.server.services.netbird;
  wildCard = {
    domains = [
      {
        main = "joka00.dev";
        sans = [ "*.joka00.dev" ];
      }
    ];
  };
in
{
  config = lib.mkIf cfg.server.enable {
    sops.secrets.relay-secret = {
      sopsFile = "${self}/secrets/services/netbird/secrets.yaml";
      mode = "0400";
    };
    sops.secrets.relay-env = {
      sopsFile = "${self}/secrets/services/netbird/secrets.yaml";
      mode = "0400";
    };
    systemd.services.netbird-relay.serviceConfig.EnvironmentFile =
      lib.mkForce config.sops.secrets.relay-env.path;
    services.netbird.server = {
      useRelay = true;
      relayAuthSecretFile = config.sops.secrets.relay-secret.path;
      relay = {
        enableNginx = false; # We use Traefik
        package = pkgs.netbird-relay;
        exposedAddress = "rels://${netbirdCfg.domain}:443";
        logLevel = "debug";
        # Optional: embedded STUN (default ports 3478); we rely on relay for NAT traversal
        stun.enable = true;
      };
    };
    networking.firewall.allowedUDPPorts = lib.mkIf netbirdCfg.relay.stun.enable netbirdCfg.relay.stun.ports;

    services.traefik.dynamicConfigOptions = {
      # /relay* → WebSocket (relay:80)
      http.routers."netbird-relay" = {
        rule = "Host(`${netbirdCfg.domain}`) && PathPrefix(`/relay`)";
        service = "netbird-relay";
        tls = wildCard;
        priority = 10;
      };
      http.services."netbird-relay".loadbalancer.servers = [
        { url = "http://127.0.0.1:${relayPort}"; }
      ];
    };
  };
}
