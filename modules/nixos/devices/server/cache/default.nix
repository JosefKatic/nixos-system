{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  options.device.server.cache = {
    enable = lib.mkEnableOption "Enable cache service";
  };

  config = lib.mkIf config.device.server.cache.enable {
    sops.secrets.cache-sig-key = {
      sopsFile = "${self}/secrets/services/hydra/secrets.yaml";
    };

    services = {
      nix-serve = {
        enable = true;
        secretKeyFile = config.sops.secrets.cache-sig-key.path;
        package = pkgs.nix-serve;
      };

      traefik = {
        dynamic.files.cache.settings = {
          http = {
            services = {
              cache.loadBalancer.servers = [
                {
                  url = "http://localhost:${toString config.services.nix-serve.port}";
                }
              ];
            };
            routers = {
              cache = {
                entryPoints = "websecure";
                rule = "Host(`cache.joka00.dev`)";
                service = "cache";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
    };
  };
}
