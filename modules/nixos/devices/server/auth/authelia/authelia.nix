{
  config,
  lib,
  ...
}:
let
  cfg = config.device.server.auth;
  authelia = "authelia-main";
in
{
  options.device.server.auth.authelia = {
    enable = lib.mkEnableOption "Enable authelia";
    lldapEnable = lib.mkEnableOption "Enable LLDAP for Authelia.";
    redisEnable = lib.mkEnableOption "Enable Redis for Authelia.";
  };
  config = lib.mkIf cfg.authelia.enable {
    services = {
      authelia.instances.main = {
        enable = true;
        secrets = {
          jwtSecretFile = "/var/lib/authelia-main/jwt_secret";
          sessionSecretFile = "/var/lib/authelia-main/session_secret";
          storageEncryptionKeyFile = "/var/lib/authelia-main/storage_key";
        };

        settings = {
          theme = "dark";
          server.address = "tcp://127.0.0.1:9091";

          # --- LDAP BACKEND CONFIGURATION ---
          authentication_backend = {
            ldap = {
              # Use 'lldap' implementation to get correct attribute defaults
              implementation = "lldap";
              address = "ldap://127.0.0.1:3890"; # Address of your LLDAP server

              # Base DN should match your LLDAP configuration
              base_dn = "dc=joka00,dc=dev";

              # Authelia needs a user to search the directory
              # LLDAP default admin is usually: uid=admin,ou=people,dc=example,dc=com
              user = "uid=admin,ou=people,dc=joka00,dc=dev";
              # LLDAP specific defaults for users and groups
              additional_users_dn = "ou=people";
              users_filter = "(&(|(uid={input})(mail={input}))(objectClass=person))";

              additional_groups_dn = "ou=groups";
              groups_filter = "(&(member={dn})(objectClass=groupOfNames))";
            };
          };
          notifier = {
            smtp = {
              address = "submission://smtp.protonmail.ch:587";
              username = "auth@joka00.dev";
              from = "auth@joka00.dev";
            };
          };

          # Standard Storage and Session config
          storage.postgres = {
            address = "unix:///run/postgresql";
            database = authelia;
            username = authelia;
          };
          session = {
            redis.host = "/var/run/redis-main/redis.sock";
            cookies = [
              {
                domain = "joka00.dev";
                authelia_url = "https://auth.joka00.dev";
                # The period of time the user can be inactive for before the session is destroyed
                inactivity = "1M";
                # The period of time before the cookie expires and the session is destroyed
                expiration = "3M";
                # The period of time before the cookie expires and the session is destroyed
                # when the remember me box is checked
                remember_me = "1y";
              }
            ];
          };

          access_control = {
            default_policy = "deny";
            # We want this rule to be low priority so it doesn't override the others
            rules = lib.mkAfter [
              {
                domain = "*.joka00.dev";
                policy = "one_factor";
              }
            ];
          };
        };

        environmentVariables = with config.sops; {
          AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.authelia-smtp.path;
        };
      };

      redis.servers."authelia-main" = {
        enable = true;
        port = 6379;
      };

      traefik = {
        dynamicConfigOptions = {
          http = {
            middlewares = {
              authelia = {
                forwardAuth = {
                  address = "http://localhost:9091/api/verify?rd=https://auth.joka00.dev/";
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
              auth.loadBalancer.servers = [
                {
                  url = "http://localhost:9001";
                }
              ];
            };
            routers = {
              auth = {
                entryPoints = "websecure";
                rule = "Host(`auth.joka00.dev`) || HostRegexp(`{subdomain:[a-z0-9]+}.joka00.dev`) && PathPrefix(`/outpost.goauthentik.io/`)";
                service = "auth";
                tls.certResolver = "cloudflare";
              };
            };
          };
        };
      };
    };
  };
}
