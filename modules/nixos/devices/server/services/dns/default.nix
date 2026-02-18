{
  config,
  lib,
  self,
  ...
}:
{
  options.device.server.services.dns = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable DNS server for homelab.";
    };
  };

  config = lib.mkIf config.device.server.services.dns.enable {
    sops.secrets =
      let
        pdnsAdminUser = config.users.users.powerdnsadmin.name;
        pdnsAdminGroup = config.users.users.powerdnsadmin.group;
        pdnsUser = config.users.users.pdns.name;
        pdnsGroup = config.users.users.pdns.group;
      in
      {
        pdns_admin_key = {
          sopsFile = "${self}/secrets/services/dns/secrets.yaml";
          owner = pdnsAdminUser;
          group = pdnsAdminGroup;
          mode = "0440";
        };
        pdns_admin_salt = {
          sopsFile = "${self}/secrets/services/dns/secrets.yaml";
          owner = pdnsAdminUser;
          group = pdnsAdminGroup;
          mode = "0440";
        };
        pdns_admin_database = {
          sopsFile = "${self}/secrets/services/dns/secrets.yaml";
          owner = pdnsAdminUser;
          group = pdnsAdminGroup;
          mode = "0440";
        };
        pdns_env = {
          sopsFile = "${self}/secrets/services/dns/secrets.yaml";
          owner = pdnsUser;
          group = pdnsGroup;
          mode = "0440";
        };
      };

    services = {
      powerdns = {
        enable = true;
        secretFile = config.sops.secrets.pdns_env.path;
        extraConfig = ''
          launch=gpgsql
          gpgsql-host=/run/postgresql
          gpgsql-dbname=pdns
          gpgsql-user=pdns
          gpgsql-dnssec=yes
          local-port=5300
          api=true
          api-key=$API_KEY
          webserver-port=9192
        '';
      };
      pdns-recursor = {
        enable = true;
        settings = {
          logging = {
            disable_syslog = false;
            timestamp = true;
          };
          recursor = {
            forward_zones = [
              {
                zone = "joka00.dev";
                forwarders = [ "127.0.0.1:5300" ];
              }
              {
                zone = "+.";
                forwarders = [
                  "1.1.1.1"
                  "1.0.0.1"
                ];
              }
            ];
          };
        };
      };
      powerdns-admin = {
        enable = true;
        secretKeyFile = config.sops.secrets.pdns_admin_key.path;
        saltFile = config.sops.secrets.pdns_admin_salt.path;
        extraArgs = [
          "-b"
          "0.0.0.0:9191"
        ];
        config = ''
          import cachelib

          BIND_ADDRESS = '0.0.0.0'
          PORT = 9191
          SQLA_DB_HOST = '127.0.0.1'
          with open('${config.sops.secrets.pdns_admin_database.path}') as file:
              SQLALCHEMY_DATABASE_URI = 'postgresql://powerdnsadmin:' + file.read() + '@127.0.0.1/powerdnsadmin'

          SESSION_TYPE = 'cachelib'
          SESSION_CACHELIB = cachelib.simple.SimpleCache()
        '';
      };
      traefik = {
        dynamic.files.dns.settings = {
          http = {
            routers.pdns = {
              rule = "Host(`dns.joka00.dev`)";
              entryPoints = [ "websecure" ];
              service = "dns";
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
            services.dns = {
              loadBalancer.servers = [
                {
                  url = "http://localhost:9191";
                }
              ];
            };
          };
        };
      };
    };
    systemd.services.powerdns-admin = {
      serviceConfig = {
        BindReadOnlyPaths = lib.mkAfter [ config.sops.secrets.pdns_admin_database.path ];
      };
    };
    networking.firewall.allowedTCPPorts = [
      5300
      53
      9191
    ];
    networking.firewall.allowedUDPPorts = [
      53
      5300
    ];
  };
}
