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

    package = lib.mkPackageOption pkgs "exportarr" { };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = ''
        See [the configuration guide](https://github.com/martabal/qbittorrent-exporter?tab=readme-ov-file#environment-variables) for available options.
      '';
    };
  };
  serviceOpts = {
    serviceConfig = {
      ExecStart = ''${pkgs.prometheus-qbittorrent-exporter}/bin/qbit-exp "$@"'';
#      ProcSubset = "pid";
#      ProtectProc = "invisible";
#      SystemCallFilter = ["@system-service" "~@privileged"];
    };
    environment = qbittorrentExporterEnvironment;
  };
}
