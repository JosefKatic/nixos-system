{
  config,
  lib,
  options,
  ...
}:
let
  inherit (lib.generators)
    mkKeyValueDefault
    toKeyValue
    ;
in
{
  security = {
    auditd.enable = true;
    audit = {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
        "-a exit,always -F arch=b32 -S execve"
      ];
    };
  };

  # A group for users that can read audit logs
  users.groups.audit = { };

  environment.etc."audit/auditd.conf".text =
    toKeyValue { mkKeyValue = mkKeyValueDefault { } " = "; }
      {
        log_group = "audit";
        # Maximum log file size in megabytes
        max_log_file = 1000;
        max_log_file_action = "rotate";
        # The amount of log files to keep around
        num_logs = 3;
        space_left = 10000;
      };

}
