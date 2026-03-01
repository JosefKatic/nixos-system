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
      description = "Default certificate resolver for Traefik (used only when acmeDomains is empty).";
    };
    localResolverEnabled = lib.mkEnableOption "Enable local DNS resolver for ACME DNS-01 challenges (used only when acmeDomains is empty).";
    acmeDomains = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            domain = lib.mkOption {
              type = lib.types.str;
              description = "Primary domain for the ACME certificate.";
            };
            extraDomainNames = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
              description = "Additional SANs (e.g. wildcard *.example.com).";
            };
          };
        }
      );
      default = [ ];
      description = "Domains to request via NixOS ACME (DNS challenge). Certs are passed to Traefik and usable by other services.";
    };
    acmeEmail = lib.mkOption {
      type = lib.types.str;
      default = "josef@joka00.dev";
      description = "Email used for ACME registration.";
    };
  };

  config = lib.mkIf cfg.traefik.enable {
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/traefik"
        ]
        ++ lib.optionals (cfg.traefik.acmeDomains != [ ]) [ "/var/lib/acme" ];
      };
    };
    sops.secrets =
      let
        traefikUser = config.users.users.traefik.name;
        traefikGroup = config.users.users.traefik.group;
        acmeGroup = "acme";
        useCloudflare = cfg.traefik.localResolverEnabled || (cfg.traefik.acmeDomains != [ ]);
      in
      lib.mkIf useCloudflare {
        cd_api_email = {
          sopsFile = "${self}/secrets/services/proxy/secrets.yaml";
          owner = traefikUser;
          group = if cfg.traefik.acmeDomains != [ ] then acmeGroup else traefikGroup;
          mode = "0440";
        };
        cd_api_token = {
          sopsFile = "${self}/secrets/services/proxy/secrets.yaml";
          owner = traefikUser;
          group = if cfg.traefik.acmeDomains != [ ] then acmeGroup else traefikGroup;
          mode = "0440";
        };
      };

    security.acme = lib.mkIf (cfg.traefik.acmeDomains != [ ]) {
      acceptTerms = true;
      defaults = {
        email = cfg.traefik.acmeEmail;
        dnsProvider = "cloudflare";
        dnsResolver = "1.1.1.1:53";
        credentialFiles = {
          CF_DNS_API_TOKEN_FILE = secrets.cd_api_token.path;
        };
        group = "acme";
      };
      certs = lib.listToAttrs (
        map (e: {
          name = e.domain;
          value = {
            domain = e.domain;
            extraDomainNames = e.extraDomainNames;
          };
        }) cfg.traefik.acmeDomains
      );
    };

    users.users.traefik.extraGroups = lib.mkIf (cfg.traefik.acmeDomains != [ ]) [ "acme" ];

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
          };
          websecure = {
            address = ":443";
            asDefault = true;
            # When using NixOS ACME (acmeDomains), certs come from file provider; no resolver.
            http.tls.certResolver = lib.mkIf (cfg.traefik.acmeDomains == [ ]) cfg.traefik.defaultCertResolver;
          };
        };

        log = {
          level = "INFO";
          filePath = "${config.services.traefik.dataDir}/traefik.log";
          format = "json";
        };

        # Built-in ACME resolvers only when not using NixOS ACME (acmeDomains).
        certificatesResolvers = lib.mkIf (cfg.traefik.acmeDomains == [ ]) {
          letsencrypt = {
            acme = {
              email = cfg.traefik.acmeEmail;
              storage = "${config.services.traefik.dataDir}/acme.json";
              httpChallenge = {
                entryPoint = "web";
              };
            };
          };
          cloudflare = lib.mkIf cfg.traefik.localResolverEnabled {
            acme = {
              email = cfg.traefik.acmeEmail;
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

      dynamicConfigOptions = lib.mkMerge [
        {
          http.routers = { };
          http.services = { };
        }
        (lib.mkIf (cfg.traefik.acmeDomains != [ ]) {
          tls.certificates = map (e: {
            certFile = "${config.security.acme.certs."${e.domain}".directory}/fullchain.pem";
            keyFile = "${config.security.acme.certs."${e.domain}".directory}/key.pem";
          }) cfg.traefik.acmeDomains;
        })
      ];
    };

    systemd.services.traefik = lib.mkIf cfg.traefik.enable {
      after = lib.mkIf (cfg.traefik.acmeDomains != [ ]) (
        map (e: "acme-${e.domain}.service") cfg.traefik.acmeDomains
      );
      serviceConfig.ReadOnlyPaths = lib.mkIf (cfg.traefik.acmeDomains != [ ]) (
        map (e: config.security.acme.certs."${e.domain}".directory) cfg.traefik.acmeDomains
      );
      environment = lib.mkIf (cfg.traefik.localResolverEnabled || (cfg.traefik.acmeDomains != [ ])) {
        CF_API_EMAIL_FILE = secrets.cd_api_email.path;
        CF_DNS_API_TOKEN_FILE = secrets.cd_api_token.path;
      };
    };
    networking.firewall.allowedTCPPorts = [
      443
      389
      8083
      9001
    ];
  };
}
