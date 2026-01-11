{ config, lib, ... }:
let
  cfg = config.device.server.auth.authelia;
  redisName = "authelia-main";
in
{
  config = lib.mkIf cfg.redisEnable {
    services.redis = {
      servers."${redisName}" = {
        enable = true;
        user = redisName;
        port = 6379;
      };
    };
  };
}
