{ config, lib, pkgs, options, ... }:

let
  cfg = config.services.prometheus.exporters.qbittorrent;
  inherit (lib)
    mkOption
    types
    boolToString
    optionalAttrs
    ;
in
{
  port = 8090;
  extraOpts = {
    url = mkOption {
      type = types.str;
      default = "http://127.0.0.1";
      description = ''
        The qBittorrent base URL.
      '';
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/etc/secrets/prometheus-qbittorrent-exporter.env";
      description = ''
        Path to the service's environment file. This path can either be a computed path in /nix/store or a path in the local filesystem.

        The environment file should NOT be stored in /nix/store as it contains passwords and/or keys in plain text.

        See [the configuration guide](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables) for available options.
      '';

      disableTracker = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Get tracker infos (needs an API request for each tracker).
        '';
      };

      timeout = mkOption {
        type = types.int;
        default = false;
        description = ''
          Get tracker infos (needs an API request for each tracker)
        '';
      };

      extraEnv = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = ''
          Extra environment variables for the exporter.
        '';
      };

    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''${pkgs.prometheus-qbittorrent-exporter}/bin/qbit-exp "$@"'';
      environment = {
        EXPORTER_PORT = toString cfg.port;
        QBITTORRENT_BASE_URL = cfg.url;
        QBITTORRENT_USERNAME = cfg.username;
        QBITTORRENT_TIMEOUT = toString cfg.timeout;
        DISABLE_TRACKER = boolToString cfg.disableTracker;
      } // cfg.extraEnv;
    } // optionalAttrs (cfg.environmentFile != null) {
      EnvironmentFile = cfg.environmentFile;
    };
  };
}
