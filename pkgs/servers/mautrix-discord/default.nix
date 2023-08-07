{ lib, buildGoModule, fetchFromGitHub, olm }:

buildGoModule rec {
  pname = "mautrix-discord";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "discord";
    rev = "v${version}";
    hash = "sha256-k9MnKNsuHHv/9Yr2LoS2ST7ljiDr9EAvD48aob1SP/w=";
  };

  buildInputs = [ olm ];

  vendorSha256 = "sha256-Hdft+0YPldmRW1xZFcoKaJ5xKgH+LDn6azuyPZt7Iog=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/tulir/mautrix-discord";
    description = "Matrix <-> Discord hybrid puppeting/relaybot bridge";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ nani8ot ];
  };
}
