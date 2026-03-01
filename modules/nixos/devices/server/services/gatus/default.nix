{ config, lib, ... }:
{
  options.device.server.services.gatus = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Gatus for monitoring services.";
    };
  };

  config = lib.mkIf config.device.server.services.gatus.enable {
    services = {
      gatus = {
        enable = true;
        settings = {
          web.port = 3001;
          ui = {
            title = "Health | joka00.dev";
            header = "Health | joka00.dev";
            logo = "https://joka00.dev/assets/logo__dark.svg";
            favicon = "https://joka00.dev/assets/logo__dark.svg";
          };
          storage = {
            type = "sqlite";
            path = "/var/lib/gatus/data.db";
          };
          endpoints = [
            {
              name = "gtnh-server";
              group = "minecraft-server";
              url = "tcp://mc.joka00.dev:25565";
              interval = "5m";
              conditions = [
                "[CONNECTED] == true"
              ];
            }
            {
              name = "gtnh-dynmap";
              group = "minecraft-server";
              url = "tcp://mc.joka00.dev:25565";
              interval = "5m";
              conditions = [
                "[CONNECTED] == true"
              ];
            }
            {
              name = "home-assistant";
              group = "homelab";
              url = "https://hass.joka00.dev/manifest.json";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
            }
            {
              name = "pdns-admin";
              group = "homelab";
              url = "https://dns.joka00.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
            }
            {
              name = "finance-sure";
              group = "homelab";
              url = "https://finance.joka00.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
            }
            {
              name = "authelia";
              url = "https://auth.joka00.dev";
              interval = "5m";
              conditions = [
                "[STATUS] == 200"
                "[RESPONSE_TIME] < 500"
              ];
            }
          ];
        };
      };
      traefik = {
        dynamicConfigOptions = {
          http = {
            routers.gatus = {
              rule = "Host(`health.joka00.dev`)";
              entryPoints = [ "websecure" ];
              service = "gatus";
              tls = {
                domains = [
                  {
                    main = "joka00.dev";
                    sans = [ "*.joka00.dev" ];
                  }
                ];
              };
            };
            services.gatus = {
              loadBalancer.servers = [
                {
                  url = "http://localhost:3001";
                }
              ];
            };
          };
        };
      };
    };
  };
}
