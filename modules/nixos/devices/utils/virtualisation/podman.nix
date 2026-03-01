{
  config,
  lib,
  ...
}:
let
  cfg = config.device.utils.virtualisation;
in
{
  options.device.utils.virtualisation.podman = {
    enable = lib.mkEnableOption "Podman virtualisation";
  };

  config = lib.mkIf cfg.podman.enable {
    virtualisation.podman = {
      enable = true;
    };
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist" = {
        directories = [
          "/var/lib/containers"
        ];
      };
    };
  };
}
