{
  config,
  lib,
  self,
  ...
}:
let
  cfg = config.device.server.services.mattermost;
in
{
  options.device.server.services.mattermost.enable =
    lib.mkEnableOption "Enable mattermost chat server";
  config = lib.mkIf cfg.enable {
    sops.secrets.mattermost-env = {
      sopsFile = "${self}/secrets/services/homelab/secrets.yaml";
      owner = "mattermost";
      group = "mattermost";
    };

    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/mattermost"
        ];
      };
    };

    services = {
      mattermost = {
        enable = true;
        siteUrl = "https://chat.joka00.dev";
        database.peerAuth = true;
        environmentFile = config.sops.secrets.mattermost-env.path;
        settings = {
          GitLabSettings = {
            Enable = true;
            Id = "$MM_GITLABSETTINGS_ID"; # While the actual value is injected at runtime
            Secret = "$MM_GITLABSETTINGS_SECRET"; # Placeholder that stays in Nix store
            # Custom Endpoints for Pocket ID
            AuthEndpoint = "https://auth.joka00.dev/authorize";
            TokenEndpoint = "https://auth.joka00.dev/api/oidc/token";
            UserApiEndpoint = "https://auth.joka00.dev/api/oidc/userinfo";
            DiscoveryEndpoint = "https://auth.joka00.dev/.well-known/openid-configuration";
            # UI Branding
            ButtonText = "joka00.dev | pocket-id";
            ButtonColor = "#000000"; # Match Pocket ID's purple/blue
            Scope = "openid profile email";
          };
        };
      };
      traefik = {
        dynamic.files.mattermost.settings = {
          http = {
            routers.chat = {
              rule = "Host(`chat.joka00.dev`)";
              entryPoints = [ "websecure" ];
              service = "chat";
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
            services.chat = {
              loadBalancer.servers = [
                {
                  url = "http://localhost:8065";
                }
              ];
            };
          };
        };
      };
    };
  };
}
