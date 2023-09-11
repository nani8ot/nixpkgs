{ lib, stdenv, fetchurl, mono, libmediainfo, sqlite, curl, makeWrapper, icu, dotnet-runtime, openssl, nixosTests, zlib }:

let
  os = if stdenv.isDarwin then "osx" else "linux";
  arch = {
    x86_64-linux = "x64";
  }."${stdenv.hostPlatform.system}" or (throw "Unsupported system: ${stdenv.hostPlatform.system}");

  hash = {
    x64-linux_hash = "sha256-WWHND/Dd8dPV9v/Aj1YaEY124SP0SOxexPzEfxibOvk=";
  }."${arch}-${os}_hash";

in stdenv.mkDerivation rec {
  pname = "sonarr";
  version = "4.0.0.669";

  src = fetchurl {
    url = "https://download.sonarr.tv/v4/develop/${version}/Sonarr.develop.${version}.linux-x64.tar.gz";
    sha256 = hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/${pname}-${version}}
    cp -r * $out/share/${pname}-${version}/.

    makeWrapper "${dotnet-runtime}/bin/dotnet" $out/bin/Sonarr \
      --add-flags "$out/share/${pname}-${version}/Sonarr.dll" \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        curl sqlite libmediainfo mono openssl icu zlib ]}

    runHook postInstall
  '';

  passthru = {
    updateScript = ./update.sh;
    tests.smoke-test = nixosTests.sonarr;
  };

  meta = with lib; {
    description = "A Usenet/BitTorrent tv downloader";
    homepage = "https://sonarr.tv/";
    changelog = "https://github.com/Sonarr/Sonarr/releases/tag/v${version}";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ edwtjo purcell nani8ot ];
    platforms = [ "x86_64-linux" ];
  };
}
