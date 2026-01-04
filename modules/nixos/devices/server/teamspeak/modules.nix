{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

with lib;

let
  ts6 = inputs.self.packages.${pkgs.system}.teamspeak6-server;
  cfg = config.services.teamspeak6;
  user = "teamspeak";
  group = "teamspeak";
in

{

  ###### interface

  options = {
    services.teamspeak6 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to run the Teamspeak6 voice communication server daemon.
        '';
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/teamspeak6-server";
        description = ''
          Directory to store TS3 database and other state/data files.
        '';
      };

      logPath = mkOption {
        type = types.path;
        default = "/var/log/teamspeak6-server/";
        description = ''
          Directory to store log files in.
        '';
      };

      voiceIP = mkOption {
        type = types.listOf types.str;
        default = [
          "0.0.0.0"
          "::"
        ];
        example = "[::]";
        description = ''
          IP on which the server instance will listen for incoming voice connections. Defaults to any IP.
        '';
      };

      defaultVoicePort = mkOption {
        type = types.port;
        default = 9987;
        description = ''
          Default UDP port for clients to connect to virtual servers - used for first virtual server, subsequent ones will open on incrementing port numbers by default.
        '';
      };

      fileTransferIP = mkOption {
        type = types.listOf types.str;
        default = [
          "0.0.0.0"
          "::"
        ];
        example = "[::]";
        description = ''
          IP on which the server instance will listen for incoming file transfer connections. Defaults to any IP.
        '';
      };

      fileTransferPort = mkOption {
        type = types.port;
        default = 30033;
        description = ''
          TCP port opened for file transfers.
        '';
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Open ports in the firewall for the TeamSpeak3 server.";
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {
    users.users.teamspeak = {
      description = "Teamspeak6 voice communication server daemon";
      group = group;
      uid = config.ids.uids.teamspeak;
      home = cfg.dataDir;
      createHome = true;
    };

    users.groups.teamspeak = {
      gid = config.ids.gids.teamspeak;
    };

    systemd.tmpfiles.rules = [
      "d '${cfg.logPath}' - ${user} ${group} - -"
    ];

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.fileTransferPort
      ];
      # subsequent vServers will use the incremented voice port, let's just open the next 10
      allowedUDPPortRanges = [
        {
          from = cfg.defaultVoicePort;
          to = cfg.defaultVoicePort + 10;
        }
      ];
    };

    systemd.services.teamspeak6-server = {
      description = "Teamspeak6 voice communication server daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      environment = {
        TSSERVER_LICENSE_ACCEPTED = "1";
        TSSERVER_DATABASE_PLUGIN = "${ts6}/lib/teamspeak/sql/";
        TSSERVER_LOG_PATH = cfg.logPath;
        TSSERVER_DB_PLUGIN = "sqlite3";
        TSSERVER_VOICE_IP = toString cfg.voiceIP;
        TSSERVER_DEFAULT_PORT = toString cfg.defaultVoicePort;
        TSSERVER_FILE_TRANSFER_PORT = toString cfg.fileTransferPort;
        TSSERVER_FILE_TRANSFER_IP = toString cfg.fileTransferIP;
      };
      serviceConfig = {
        ExecStart = ''
          ${ts6}/bin/tsserver
        '';
        WorkingDirectory = cfg.dataDir;
        User = user;
        Group = group;
        Restart = "on-failure";
      };
    };
  };
}
