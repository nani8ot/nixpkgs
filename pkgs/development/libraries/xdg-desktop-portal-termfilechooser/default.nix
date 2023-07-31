{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, meson
, ninja
, pkg-config
, wayland-protocols
, wayland-scanner
, inih
, libdrm
, mesa
, scdoc
, systemd
, wayland
, kitty
}:

stdenv.mkDerivation rec {
  pname = "xdg-desktop-portal-termfilechooser";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "nani8ot";
    repo = pname;
    rev = "main";
    sha256 = "sha256-645hoLhQNncqfLKcYCgWLbSrTRUNELh6EAdgUVq3ypM=";
  };

  strictDeps = true;
  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [ meson ninja pkg-config scdoc wayland-scanner makeWrapper ];
  buildInputs = [ inih libdrm mesa systemd wayland wayland-protocols ];

  postInstall = ''
    wrapProgram $out/libexec/xdg-desktop-portal-termfilechooser --prefix PATH ":" ${lib.makeBinPath [ kitty ]}
  '';

  mesonFlags = [
    "-Dsd-bus-provider=libsystemd"
  ];

  meta = with lib; {
    homepage = "https://github.com/GermainZ/xdg-desktop-portal-termfilechooser";
    description = "xdg-desktop-portal backend for wlroots and the likes of ranger";
    maintainers = with maintainers; [ nani8ot ];
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
