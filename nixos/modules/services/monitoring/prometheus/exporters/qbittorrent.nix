{ config, lib, pkgs, options, ... }:

let
  cfg = config.services.prometheus.exporters.qbittorrent;
  qbittorrentExporterEnvironment = (
    lib.mapAttrs (_: toString) cfg.environment
  ) // {
    EXPORTER_PORT = toString cfg.port;
    URL = cfg.url;
  };
in
{
  port = 8090;
  extraOpts = {
    url = lib.mkOption {
      type = lib.types.str;
      default = "http://127.0.0.1";
      description = ''
        The qBittorrent base URL.
      '';
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        See [the configuration guide](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables) for available options.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/etc/secrets/prometheus-qbittorrent-exporter.env";
      description = ''
        Path to the service's environment file. This path can either be a computed path in /nix/store or a path in the local filesystem.

        The environment file should NOT be stored in /nix/store as it contains passwords and/or keys in plain text.

        See [the configuration guide](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables) for available options.
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''${pkgs.prometheus-qbittorrent-exporter}/bin/qbit-exp "$@"'';
    } // lib.optionalAttrs (cfg.environmentFile != null) {
      EnvironmentFile = cfg.environmentFile;
    };
    environment = qbittorrentExporterEnvironment;
  };
}
