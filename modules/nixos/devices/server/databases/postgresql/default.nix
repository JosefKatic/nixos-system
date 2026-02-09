{
  config,
  lib,
  ...
}:
{
  options.device.server.databases.postgresql.enable = lib.mkEnableOption "Enable postgresql";
  config = lib.mkIf config.device.server.databases.postgresql.enable {
    services.postgresql = {
      enable = true;
      ensureDatabases =
        [ ]
        ++ lib.optionals config.device.server.services.dns.enable [
          "pdns"
          "powerdnsadmin"
        ]
        ++ lib.optionals config.device.server.auth.authelia.lldapEnable [
          "lldap"
        ]
        ++ lib.optionals config.device.server.auth.authelia.enable [
          "authelia-main"
        ]
        ++ lib.optionals config.device.server.hydra.enable [
          "hydra"
        ]
        ++ lib.optionals config.device.server.services.sure.enable [
          "sure"
        ];
      ensureUsers =
        [ ]
        ++ lib.optionals config.device.server.services.dns.enable [
          {
            name = "pdns";
            ensureDBOwnership = true;
          }
          {
            name = "powerdnsadmin";
            ensureDBOwnership = true;
          }
        ]
        ++ lib.optionals config.device.server.auth.authelia.enable [
          {
            name = "authelia-main";
            ensureDBOwnership = true;
          }
        ]
        ++ lib.optionals config.device.server.auth.authelia.lldapEnable [
          {
            name = "lldap";
            ensureDBOwnership = true;
            ensureClauses = {
              createrole = true;
            };
          }
        ]
        ++ lib.optionals config.device.server.hydra.enable [
          {
            name = "hydra";
            ensureDBOwnership = true;
            ensureClauses = {
              createrole = true;
            };
          }
        ]
        ++ lib.optionals config.device.server.services.sure.enable [
          {
            name = "sure";
            ensureDBOwnership = true;
          }
        ];
    };
    environment.persistence = lib.mkIf config.device.core.storage.enablePersistence {
      "/persist".directories = [
        "/var/lib/postgresql"
      ];
    };
  };
}
