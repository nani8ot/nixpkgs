{ lib, stdenv, fetchFromGitHub, jdk8 }:

stdenv.mkDerivation rec {
  pname = "async-profiler";
  version = "1.8.6";

  src = fetchFromGitHub {
    owner = "jvm-profiling-tools";
    repo = "async-profiler";
    rev = "v${version}";
    sha256 = "sha256-MtRO0tbo4kDHcQmir8ulv0q1Qh+KnKIshb1NDtu1SKg=";
  };

  buildInputs = [ jdk8 ];

  installPhase = ''
    runHook preInstall
    install -D "$src/profiler.sh" "$out/bin/async-profiler"
    install -D build/jattach "$out/bin/jattach"
    install -D build/libasyncProfiler.so "$out/lib/libasyncProfiler.so"
    install -D -t "$out/share/java/" build/*.jar
    runHook postInstall
  '';

  patches = [
    # https://github.com/jvm-profiling-tools/async-profiler/pull/428
    ./0001-Fix-darwin-build.patch
  ];

  fixupPhase = ''
    substituteInPlace $out/bin/async-profiler \
      --replace 'JATTACH=$SCRIPT_DIR/build/jattach' \
                'JATTACH=${placeholder "out"}/bin/jattach' \
      --replace 'PROFILER=$SCRIPT_DIR/build/libasyncProfiler.so' \
                'PROFILER=${placeholder "out"}/lib/libasyncProfiler.so'
  '';

  meta = with lib; {
    description = "A low overhead sampling profiler for Java that does not suffer from Safepoint bias problem";
    homepage    = "https://github.com/jvm-profiling-tools/async-profiler";
    license     = licenses.asl20;
    maintainers = with maintainers; [ mschuwalow ];
    platforms   = platforms.all;
  };
}
