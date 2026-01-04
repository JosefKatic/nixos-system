{ config, lib, ... }:
let
  cfg = config.device.server.auth.authelia;
in
{
  config = lib.mkIf cfg.redisEnable {
    services.redis = {
      enable = true;
      servers."authelia-main" = {
        port = 6379;
      };
    };
  };
}
