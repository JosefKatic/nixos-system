{ config, lib, ... }:
let
  cfg = config.device.server.services.netbird.client;
in
{
  options.device.server.services.netbird.client = {
    enable = lib.mkEnableOption "Enable Netbird client";
    ui.enable = lib.mkEnableOption "Enable Netbird client UI";
    managementUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://vpn.joka00.dev";
      description = "Management and admin URL for the Netbird client (sets server.managementUrl and server.adminUrl from PR 487367).";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.persistence = {
      "/persist" = {
        directories = [ "/var/lib/netbird" ];
      };
    };
    environment.variables = {
      NB_MANAGEMENT_URL = "https://vpn.joka00.dev";
      NB_ADMIN_URL = "https://vpn.joka00.dev";
    };
    services.netbird = {
      enable = true;
      useRoutingFeatures = if config.device.type == "server" then "server" else "client";
      ui.enable = cfg.ui.enable;
    };
  };
}
