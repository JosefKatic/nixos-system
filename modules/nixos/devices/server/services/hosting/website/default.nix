{
  inputs,
  config,
  pkgs,
  lib,
  ...
}:
let
  website = inputs.web.packages.${pkgs.stdenv.hostPlatform.system}.default;
  # pgpKey = "${self}home/joka/pgp.asc";
  # sshKey = "${self}/home/joka/ssh.pub";
  days = n: toString (n * 60 * 60 * 24);
in
{
  options.device.server.services.hosting.website = {
    enable = lib.mkEnableOption "Enable website hosting";
  };
  config = lib.mkIf config.device.server.services.hosting.website.enable {
    services.nginx = {
      enable = true;
      virtualHosts = {
        "joka00.dev" = {
          listen = [
            {
              addr = "127.0.0.1";
              port = 8081;
            }
          ];
          locations = {
            "/" = {
              root = "${website}/public";
            };
            "/assets/" = {
              root = "${website}/public";
              extraConfig = ''
                add_header Cache-Control "max-age=${days 30}";
              '';
            };
          };
        };
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          routers.website = {
            rule = "Host(`joka00.dev`)";
            entryPoints = [ "websecure" ];
            service = "website";
            tls.certResolver = "letsencrypt";
          };
          services.website = {
            loadBalancer.servers = [
              {
                url = "http://127.0.0.1:8081";
              }
            ];
          };
        };
      };
    };
  };
}
