{ lib
, stdenv
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "prometheus-qbittorrent-exporter";
  version = "1.2.6";

  src = fetchFromGitHub {
    owner = "martabal";
    repo = "qbittorrent-exporter";
    rev = "v${version}";
    hash = "sha256-WXId+9CKjcMmBkgSFEalUqa9m/04fOuprIpGF1wUuTs=";
  } + "/src"; # go.mod not in root

  vendorHash = "sha256-G+r3V6oDtr57pmk2Rrudbk9cnf0wcldJ2TnYEEzlG2o=";

  nativeCheckInputs = [
  ];

  meta = with lib; {
    homepage = "https://github.com/martabal/qbittorrent-exporter";
    description = "Prometheus exporter for qBittorrent";
    changelog = "https://github.com/martabal/qbittorrent-exporter/releases/tag/v${version}";
    license = licenses.mit;
    maintainers = with maintainers; [ nani8ot ];
    platforms = platforms.unix;
  };
}
