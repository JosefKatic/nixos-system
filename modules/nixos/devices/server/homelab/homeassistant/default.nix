{
  config,
  lib,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.device.server.homelab;
in
{
  options.device.server.homelab = {
    homeassistant = {
      enable = mkEnableOption "Home Assistant";
    };
  };

  config = mkIf cfg.homeassistant.enable {
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/containers"
        ];
      };
    };
    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services.homeAssistant.loadBalancer.servers = [
            {
              url = "http://localhost:8123";
            }
          ];

          routers.homeAssistant = {
            entryPoints = [ "websecure" ];
            rule = "Host(`hass.joka00.dev`)";
            service = "homeAssistant";
            tls.certResolver = "cloudflare";
          };
        };
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
      containers.homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:stable";
        volumes = [
          "home-assistant:/config"
          "/run/dbus:/run/dbus:ro"
        ];
        environment.TZ = "Europe/Prague";
        extraOptions = [
          "--network=host"
          "--cap-add=NET_RAW"
          "--cap-add=NET_ADMIN"
          "--device=/dev/ttyACM0:/dev/ttyACM0"
        ];
      };
    };
    networking.firewall.interfaces."eno2".allowedTCPPorts = [
      21063
      21064
      8123
    ];
    networking.firewall.interfaces."eno2".allowedUDPPorts = [
      5353
      21063
      21064
    ];
  };
}
