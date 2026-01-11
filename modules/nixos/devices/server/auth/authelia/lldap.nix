{
  config,
  lib,
  self,
  ...
}:
let
  cfg = config.device.server.auth.authelia;
in
{
  config = lib.mkIf cfg.lldapEnable {
    services = {
      lldap = {
        enable = true;
        settings = {
          ldap_base_dn = "dc=joka00,dc=dev";
          ldap_user_email = "josef@joka00.dev";
          ldap_user_pass_file = config.sops.secrets.lldap-password.path;
          force_ldap_user_pass_reset = "always";
          database_url = "postgresql://lldap@localhost/lldap?host=/run/postgresql";
        };
        environment = {
          LLDAP_JWT_SECRET_FILE = config.sops.secrets.lldap-jwt-secret.path;
          LLDAP_KEY_SEED_FILE = config.sops.secrets.lldap-key-seed.path;
        };
      };
      traefik = {
        dynamicConfigOptions = {
          http = {
            lldap = {
              lldap.loadBalancer.servers = [
                {
                  url = "http://localhost:17170";
                }
              ];
            };
            routers = {
              lldap = {
                entryPoints = "websecure";
                rule = "Host(`ldap.auth.joka00.dev`)";
                service = "lldap";
                tls.certResolver = "cloudflare";
              };
            };
          };
        };
      };
    };

    systemd.services.lldap =
      let
        dependencies = [
          "postgresql.service"
        ];
      in
      {
        # LLDAP requires PostgreSQL to be running
        after = dependencies;
        requires = dependencies;
        # DynamicUser screws up sops-nix ownership because
        # the user doesn't exist outside of runtime.
        serviceConfig.DynamicUser = lib.mkForce false;
      };

    # Setup a user and group for LLDAP
    users = {
      users.lldap = {
        group = "lldap";
        isSystemUser = true;
      };
      groups.lldap = { };
    };

    sops.secrets = {
      lldap-password = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
        owner = "lldap";
      };
      lldap-jwt-secret = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
        owner = "lldap";
      };
      lldap-key-seed = {
        sopsFile = "${self}/secrets/services/auth/secrets.yaml";
        owner = "lldap";
      };
    };
  };
}
