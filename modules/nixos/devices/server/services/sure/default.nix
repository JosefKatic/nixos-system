{
  config,
  lib,
  self,
  ...
}:
{
  options.device.server.services.sure = {
    enable = lib.mkEnableOption "Enable sure";
  };

  config = lib.mkIf config.device.server.services.sure.enable {
    sops.secrets = {
      sure-rails-secret = {
        sopsFile = "${self}/secrets/services/homelab/secrets.yaml";
        owner = "root";
        group = "root";
        mode = "0400";
      };
      sure-db-pass = {
        sopsFile = "${self}/secrets/services/homelab/secrets.yaml";
        owner = "root";
        group = "root";
        mode = "0400";
      };
    };

    services = {
      sure = {
        enable = true;
        secretKeyBaseFile = config.sops.secrets.sure-rails-secret.path;
        port = 3002;
        environment = {
          APP_DOMAIN = "finance.joka00.dev";
        };
        database = {
          passwordFile = config.sops.secrets.sure-db-pass.path;
          createLocally = true;
        };
        redis = {
          createLocally = true;
          port = 6380;
        };
        puma.workers = 2;
      };
      traefik = {
        dynamic.files.sure.settings = {
          http = {
            services.sure.loadBalancer.servers = [
              {
                url = "http://localhost:3002";
              }
            ];
            routers.sure = {
              entryPoints = [ "websecure" ];
              rule = "Host(`finance.joka00.dev`)";
              service = "sure";
              tls = {
                certResolver = "cloudflare";
                domains = [
                  {
                    main = "joka00.dev";
                    sans = [ "*.joka00.dev" ];
                  }
                ];
              };
            };
          };
        };
      };
    };
  };
}
