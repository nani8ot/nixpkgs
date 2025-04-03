{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.audiobookshelf;
in
{
  options = {
    services.audiobookshelf = {
      enable = mkEnableOption "Audiobookshelf, self-hosted audiobook and podcast server";

      package = mkPackageOption pkgs "audiobookshelf" { };

      dataDir = mkOption {
        description = "Path to Audiobookshelf config and metadata inside of /var/lib.";
        default = "audiobookshelf";
        type = types.str;
      };

      host = mkOption {
        description = "The host Audiobookshelf binds to.";
        default = "127.0.0.1";
        example = "0.0.0.0";
        type = types.str;
      };

      port = mkOption {
        description = "The TCP port Audiobookshelf will listen on.";
        default = 8000;
        type = types.port;
      };

      user = mkOption {
        description = "User account under which Audiobookshelf runs.";
        default = "audiobookshelf";
        type = types.str;
      };

      group = mkOption {
        description = "Group under which Audiobookshelf runs.";
        default = "audiobookshelf";
        type = types.str;
      };

      openFirewall = mkOption {
        description = "Open ports in the firewall for the Audiobookshelf web interface.";
        default = false;
        type = types.bool;
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.audiobookshelf = {
      description = "Audiobookshelf is a self-hosted audiobook and podcast server";

      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig =
        {
          Type = "simple";
          User = cfg.user;
          Group = cfg.group;
          StateDirectory = cfg.dataDir;
          WorkingDirectory = "/var/lib/${cfg.dataDir}";
          ExecStart = "${cfg.package}/bin/audiobookshelf --host ${cfg.host} --port ${toString cfg.port}";
          Restart = "on-failure";
          # Hardening
          LockPersonality = true;
          NoNewPrivileges = true;
          PrivateDevices = true;
          PrivateIPC = true;
          PrivateTmp = true;
          ProcSubset = "pid";
          ProtectClock = true;
          ProtectControlGroups = true;
          ProtectHome = true;
          ProtectHostname = true;
          ProtectKernelLogs = true;
          ProtectKernelModules = true;
          ProtectKernelTunables = true;
          ProtectProc = "invisible";
          RemoveIPC = true;
          RestrictAddressFamilies = [
            "AF_INET"
            "AF_INET6"
          ];
          RestrictNamespaces = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          SystemCallArchitectures = "native";
          SystemCallFilter = [
            "~@mount"
            "~@swap"
            "~@resources"
            "~@reboot"
            "~@raw-io"
            "~@obsolete"
            "~@module"
            "~@debug"
            "~@cpu-emulation"
            "~@clock"
            "~@privileged"
          ];
          UMask = "0077";
        }
        // (
          if (cfg.port < 1024) then
            {
              AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
              CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
            }
          else
            {
              # A private user cannot have process capabilities on the host's user
              # namespace and thus CAP_NET_BIND_SERVICE has no effect.
              PrivateUsers = true;
              CapabilityBoundingSet = false;
            }
        );
    };

    users.users = mkIf (cfg.user == "audiobookshelf") {
      audiobookshelf = {
        isSystemUser = true;
        group = cfg.group;
        home = "/var/lib/${cfg.dataDir}";
      };
    };

    users.groups = mkIf (cfg.group == "audiobookshelf") {
      audiobookshelf = { };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [ cfg.port ];
    };
  };

  meta.maintainers = with maintainers; [ wietsedv ];
}
