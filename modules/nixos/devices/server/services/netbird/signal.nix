{ config, lib, ... }:
let
  netbirdCfg = config.services.netbird.server;
  sigPort = toString netbirdCfg.signal.port;
  grpcPort = "10000";
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
    services.netbird.server.signal = {
      port = 6968;
      logLevel = "DEBUG";
    };

    services.traefik = {
      dynamicConfigOptions = {
        http.routers."netbird-signal" = {
          rule = "Host(`${netbirdCfg.domain}`) && PathPrefix(`/signalexchange.SignalExchange/`)";
          service = "netbird-signal";
          tls = wildCard;
          priority = 10;
        };
        http.services."netbird-signal".loadbalancer = {
          servers = [ { url = "h2c://127.0.0.1:${grpcPort}"; } ];
          serversTransport = "netbird-grpc";
        };

        # /ws-proxy/signal* → WebSocket (signal:80 → sigPort)
        http.routers."netbird-signal-ws" = {
          rule = "Host(`${netbirdCfg.domain}`) && PathPrefix(`/ws-proxy/signal`)";
          service = "netbird-signal-ws";
          tls = wildCard;
          priority = 10;
        };
        http.services."netbird-signal-ws".loadbalancer.servers = [
          { url = "http://127.0.0.1:${sigPort}"; }
        ];
      };
    };
  };
}
