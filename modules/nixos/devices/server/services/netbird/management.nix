{
  config,
  lib,
  self,
  ...
}:
let
  netbirdCfg = config.services.netbird.server;
  mgmtPort = "${toString netbirdCfg.management.port}";
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
    sops.secrets = {
      store-key = {
        sopsFile = "${self}/secrets/services/netbird/secrets.yaml";
        mode = "0400";
      };
      # Required by management module (TURNConfig.Secret); use a file so it's not world-readable in the store
      turn-secret = {
        sopsFile = "${self}/secrets/services/netbird/secrets.yaml";
        mode = "0400";
      };
    };

    services.netbird.server.management.extraOptions = [ "--metrics-port=9092" ];
    services.netbird.server.management = {
      port = 6969;
      logLevel = "DEBUG";
      disableAnonymousMetrics = true;
      domain = netbirdCfg.domain;
      turnDomain = netbirdCfg.domain;
      # So the management API validates JWTs from Pocket-ID
      oidcConfigEndpoint = "https://auth.joka00.dev/.well-known/openid-configuration";
      singleAccountMode.enable = false;
      settings = {
        # Generate this with `wg genkey`
        DataStoreEncryptionKey = {
          _secret = config.sops.secrets.store-key.path;
        };
        # TURN config: Secret from file (not world-readable); empty Turns when using relay only
        TURNConfig = {
          Secret = {
            _secret = config.sops.secrets.turn-secret.path;
          };
          Turns = [ ];
        };
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        # Relaxed timeouts for gRPC (management API + Signal); avoids 504 and "didn't receive registration header"
        http.serversTransports."netbird-grpc" = {
          forwardingTimeouts = {
            responseHeaderTimeout = "0";
            idleConnTimeout = "300s";
            readIdleTimeout = "30s";
            pingTimeout = "30s";
          };
        };

        # /api/* → HTTP (management:80)
        http.routers."netbird-mgmt" = {
          rule = "Host(`${netbirdCfg.domain}`) && PathPrefix(`/api`)";
          service = "netbird-mgmt";
          tls = wildCard;
          priority = 10;
        };
        http.services."netbird-mgmt".loadbalancer.servers = [ { url = "http://127.0.0.1:${mgmtPort}"; } ];

        # /ws-proxy/management* → WebSocket (management:80)
        http.routers."netbird-mgmt-ws" = {
          rule = "Host(`${netbirdCfg.domain}`) && PathPrefix(`/ws-proxy/management`)";
          service = "netbird-mgmt-ws";
          tls = wildCard;
          priority = 10;
        };
        http.services."netbird-mgmt-ws".loadbalancer.servers = [
          { url = "http://127.0.0.1:${mgmtPort}"; }
        ];

        # /management.ManagementService/* → gRPC (management:80, h2c)
        http.routers."netbird-api" = {
          rule = "Host(`${netbirdCfg.domain}`) && PathPrefix(`/management.ManagementService/`)";
          service = "netbird-api";
          tls = wildCard;
          priority = 10;
        };
        http.services."netbird-api".loadbalancer = {
          servers = [ { url = "h2c://127.0.0.1:${mgmtPort}"; } ];
          serversTransport = "netbird-grpc";
        };
      };
    };
  };
}
