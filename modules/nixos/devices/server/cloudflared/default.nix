{
  config,
  lib,
  self,
  ...
}:
let
  inherit (lib) mkOption types;
in
{
  options.device.server.cloudflared = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable the Cloudflare tunnel.";
    };
  };
  config = lib.mkIf config.device.server.cloudflared.enable {
    sops.secrets."tunnel-json" = {
      # Path to the encrypted file in your git repo
      sopsFile = "${self}/secrets/services/cloudflared/secrets.json";
      format = "json";
      key = "";
      # The cloudflared service runs as a specific user
      mode = "0400";
    };

    services.cloudflared = {
      enable = true;
      tunnels = {
        "c4b2f0fe-a6e2-42cf-995b-5741faa7bffc" = {
          # Point to the path where sops-nix mounts the decrypted file
          credentialsFile = config.sops.secrets."tunnel-json".path;
          default = "http_status:404";
        };
      };
    };
  };
}
