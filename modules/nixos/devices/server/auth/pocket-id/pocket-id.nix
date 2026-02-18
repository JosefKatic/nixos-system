{
  config,
  lib,
  self,
  ...
}:
let
  cfg = config.device.server.auth.pocket-id;
  secrets = config.sops.secrets;
in
{
  options.device.server.auth.pocket-id = {
    enable = lib.mkEnableOption "Enable pocket-id authentication";
    lldapEnable = lib.mkEnableOption "Enable pocket-id authentication";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets = {
      pocket-id-encryption = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
      };
      pocket-id-maxmind = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
      };
    };
    services = {
      pocket-id = {
        enable = true;
        credentials = {
          ENCRYPTION_KEY = secrets.pocket-id-encryption.path;
          MAXMIND_LICENSE_KEY = secrets.pocket-id-maxmind.path;
        };
        settings = {
          APP_URL = "https://auth.joka00.dev";
          TRUST_PROXY = true;
        };
      };
      traefik = {
        dynamic.files.pocket-id.settings = {
          http = {
            middlewares = {
              pocket-id = {
                forwardAuth = {
                  address = "http://localhost:1411/api/verify?rd=https://auth.joka00.dev/";
                  trustForwardHeader = true;
                  authResponseHeaders = [
                    "Remote-User"
                    "Remote-Groups"
                    "Remote-Email"
                    "Remote-Name"
                  ];
                };
              };
            };

            services = {
              pocket-id.loadBalancer.servers = [
                {
                  url = "http://localhost:1411";
                }
              ];
            };
            routers = {
              pocket-id = {
                entryPoints = "websecure";
                rule = "Host(`auth.joka00.dev`)";
                service = "pocket-id";
                tls = {
                  certResolver = "cloudflare";
                  domains = [
                    {
                      main = "auth.joka00.dev";
                      sans = [ "*.auth.joka00.dev" ];
                    }
                  ];
                };
              };
            };
          };
        };
      };
    };
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          {
            directory = "/var/lib/pocket-id";
            user = "pocket-id";
            group = "pocket-id";
          }
        ];
      };
    };
  };
}
