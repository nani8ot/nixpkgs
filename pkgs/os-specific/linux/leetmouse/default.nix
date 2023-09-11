{ lib, stdenv, kernel, fetchFromGithub }:

stdenv.mkDerivation rec {
  pname = "leetmouse-${kernel.version}";
  version = "unstable-2023-08-13";

  src = fetchFromGithub {
    owner = "systemofapwne";
    repo = "leetmouse";
    rev = "2406c9614056237319e108b1419d2920c772c0ef";
    sha256 = "sha256-d2WH8Zv7F0phZmEKcDiaak9On+Mo9bAFhMulT/N5FW1=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELRELEASE=${kernel.modDirVersion}"                                 # 3
    "KERNEL_DIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"    # 4
    "INSTALL_MOD_PATH=$(out)"                                               # 5
  ];


  #installPhase = ''
  #  install -D leetmouse.ko -t "$out/lib/modules/${kernel.modDirVersion}/kernel/drivers/leetmouse/"
  #'';

  meta = with lib; {
    homepage = "https://github.com/systemofapwne/leetmouse";
    description = "Linux kernel driver for custom mouse acceleration curves";
    license = licenses.gpl2;
    maintainers = with maintainers; [ nani8ot ];
    platforms = [ "x86_64-linux" ];
    broken = versionOlder kernel.version "6.0";
  };
}
