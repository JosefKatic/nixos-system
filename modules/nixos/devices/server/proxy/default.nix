{
  config,
  lib,
  self,
  ...
}:
let
  cfg = config.device.server.proxy;
  secrets = config.sops.secrets;
in
{
  options.device.server.proxy.traefik = {
    enable = lib.mkEnableOption "Enable Traefik reverse proxy.";
    enableDashboard = lib.mkEnableOption "Enable Traefik dashboard.";
    defaultCertResolver = lib.mkOption {
      type = lib.types.str;
      default = "cloudflare";
      description = "Default certificate resolver for Traefik.";
    };
  };

  config = lib.mkIf cfg.traefik.enable {
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [ "/var/lib/traefik" ];
      };
    };
    sops.secrets =
      let
        traefikUser = config.users.users.traefik.name;
        traefikGroup = config.users.users.traefik.group;
      in
      {
        cd_api_email = {
          sopsFile = "${self}/secrets/services/proxy/secrets.yaml";
          owner = traefikUser;
          group = traefikGroup;
          mode = "0440";
        };
        cd_api_token = {
          sopsFile = "${self}/secrets/services/proxy/secrets.yaml";
          owner = traefikUser;
          group = traefikGroup;
          mode = "0440";
        };
      };

    services.traefik = lib.mkIf cfg.traefik.enable {
      enable = true;
      staticConfigOptions = {
        tls = {
          options = {
            modern = {
              minVersion = "VersionTLS13";
            };
            intermediate = {
              minVersion = "VersionTLS12";
              cipherSuites = [
                "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
                "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
                "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384"
                "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
                "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305"
                "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305"
              ];
            };
          };
        };
        entryPoints = {
          web = {
            address = ":80";
            asDefault = true;
            http.redirections.entrypoint = {
              to = "websecure";
              scheme = "https";
            };
            proxyProtocol = {
              insecure = false;
              trustedIPs = [ ];
            };
            forwardedHeaders = {
              insecure = false;
              trustedIPs = [ ];
            };
          };
          websecure = {
            address = ":443";
            asDefault = true;
            http.tls.certResolver = cfg.traefik.defaultCertResolver;
            proxyProtocol = {
              insecure = false;
              trustedIPs = [ ];
            };
            forwardedHeaders = {
              insecure = false;
              trustedIPs = [ ];
            };
          };
        };

        log = {
          level = "INFO";
          filePath = "${config.services.traefik.dataDir}/traefik.log";
          format = "json";
        };

        certificatesResolvers = {
          letsencrypt = {
            acme = {
              email = "josef@joka00.dev";
              storage = "${config.services.traefik.dataDir}/acme.json";
            };
          };
          cloudflare = {
            acme = {
              email = "josef@joka00.dev";
              storage = "${config.services.traefik.dataDir}/acme.json";
              dnsChallenge = {
                provider = "cloudflare";
                resolvers = [
                  "1.1.1.1:53"
                  "1.0.0.1:53"
                ];
              };
            };
          };
        };

        api.dashboard = cfg.traefik.enableDashboard;
      };

      dynamicConfigOptions = {
        http.routers = { };
        http.services = { };
      };
    };
    systemd.services.traefik.environment = {
      CF_API_EMAIL_FILE = secrets.cd_api_email.path;
      CF_DNS_API_TOKEN_FILE = secrets.cd_api_token.path;
    };
    networking.firewall.allowedTCPPorts = [
      80
      443
      389
      8083
      9001
    ];
  };
}
