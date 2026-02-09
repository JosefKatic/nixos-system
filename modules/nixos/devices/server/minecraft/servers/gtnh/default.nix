{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.services.minecraft-servers.servers.gtnh;
in
{
  config = lib.mkIf config.device.server.minecraft.enable {
    networking.firewall = {
      allowedTCPPorts = [ cfg.serverProperties.server-port ];
      allowedUDPPorts = [ cfg.serverProperties.server-port ];
    };

    services.minecraft-servers.servers.gtnh = rec {
      enable = true;
      enableReload = true;
      package = pkgs.callPackage ./gtnh.nix { };
      jvmOpts = "-Xms6G -Xmx6G -Dfml.readTimeout=180";
      whitelist = import ../../whitelist.nix;
      serverProperties = {
        level-type = "rwg";
        difficulty = 2;
        spawn-protection = 1;
        server-port = 25565;
        online-mode = true;
        white-list = true;
        max-tick-time = -1; # unlimited
        level-seed = "4387134805370572030";
        enable-rcon = true;
        "rcon.password" = "@RCON_PASSWORD@";
        "rcon.port" = 24472;
      };
      files = {
        config = "${package}/lib/config";
        serverutilities = "${package}/lib/serverutilities";
        "serverutilities/serverutilities.cfg" = ./configs/serverutilities.cfg;
        "config/JourneyMapServer/world.cfg" = ./configs/journeymap-world.cfg;
        # "config/SpecialMobs.cfg" = ./configs/SpecialMobs.cfg;
        "dynmap/configuration.txt" = {
          format = pkgs.formats.yaml { };
          value = (import ./configs/dynmap.default.nix) // {
            webserver-port = 8123;
            deftemplatesuffix = "hires";
            defaultmap = "surface";
            defaultworld = "world";
          };
        };
      };
      symlinks = {
        "mods/bungeeforge-1.7.10.jar" = pkgs.fetchurl rec {
          pname = "bungeeforge";
          version = "1.0.6";
          url = "https://github.com/caunt/BungeeForge/releases/download/v${version}/bungeeforge-1.7.10.jar";
          hash = "sha256-Y10ExD0nn1pkjhrgsSq9eiww5+n0J5skoC2EetXCVGM=";
        };
        "mods/gtnh-web-map-0.3.45.jar" = pkgs.fetchurl rec {
          pname = "gtnh-web-map";
          version = "0.3.45";
          url = "https://github.com/GTNewHorizons/GTNH-Web-Map/releases/download/${version}/gtnh-web-map-${version}.jar";
          hash = "sha256-e9qt0egZSQxZHlfozfoGLIDbvyyy59df0pYkHSfMRAQ=";
        };
      };
    };

    services.traefik =
      let
        dynmapCfg = cfg.files."dynmap/configuration.txt".value;
      in
      {
        dynamicConfigOptions = {
          http = {
            services = {
              mc-dynmap.loadBalancer.servers = [
                {
                  url = "http://localhost:${toString dynmapCfg.webserver-port}";
                }
              ];
            };
            routers = {
              mc-dynmap = {
                entryPoints = "websecure";
                rule = "Host(`mc.joka00.dev`)";
                service = "mc-dynmap";
                tls.certResolver = "letsencrypt";
              };
            };
          };
        };
      };
  };
}
