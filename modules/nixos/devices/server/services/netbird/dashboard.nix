{ config, lib, ... }:
let
  netbirdCfg = config.services.netbird.server;
  cid = "netbird";
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
    services.netbird.server.dashboard = {
      enable = true;
      enableNginx = true;
      settings = {
        # OIDC issuer (no trailing slash per Pocket-ID docs)
        AUTH_AUTHORITY = "https://auth.joka00.dev";
        AUTH_AUDIENCE = cid;
        AUTH_CLIENT_ID = cid;
        AUTH_SUPPORTED_SCOPES = "openid profile email groups";
        AUTH_REDIRECT_URI = "/nb-auth";
        AUTH_SILENT_REDIRECT_URI = "/nb-silent-auth";
        USE_AUTH0 = false;
      };
    };
    services.nginx.virtualHosts.${netbirdCfg.domain}.listen = [
      {
        port = 6942;
        addr = "127.0.0.1";
      }
    ];

    services.traefik = {
      dynamicConfigOptions = {
        # /* → HTTP (dashboard:80) — catch-all, lowest priority
        http.routers."netbird-dash" = {
          rule = "Host(`${netbirdCfg.domain}`)";
          service = "netbird-dash";
          tls = wildCard;
          priority = 1;
        };
        http.services."netbird-dash".loadbalancer.servers = [ { url = "http://127.0.0.1:6942"; } ];
      };
    };
  };
}
