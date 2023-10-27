{ lib
, pkg-config
, buildGoModule
, fetchFromGitHub
, makeWrapper
, coreutils
, gnupg
, gnutar
, squashfsTools
, debootstrap
, callPackage
}:

let
  bins = [
    coreutils
    gnupg
    gnutar
    squashfsTools
    debootstrap
  ];
in
buildGoModule rec {
  pname = "distrobuilder";
  version = "3.0";

  vendorHash = "sha256-pFrEkZnrcx0d3oM1klQrNHH+MiLvO4V1uFQdE0kXUqM=";

  src = fetchFromGitHub {
    owner = "lxc";
    repo = "distrobuilder";
    rev = "refs/tags/distrobuilder-${version}";
    sha256 = "sha256-JfME9VaqaQnrhnzhSLGUy9uU+tki1hXdnwqBUD/5XH0=";
    fetchSubmodules = false;
  };

  buildInputs = bins;

  passthru.generator = callPackage ./generator.nix { inherit src version; };

  # tests require a local keyserver (mkg20001/nixpkgs branch distrobuilder-with-tests) but gpg is currently broken in tests
  doCheck = false;

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ] ++ bins;

  postInstall = ''
    wrapProgram $out/bin/distrobuilder --prefix PATH ":" ${lib.makeBinPath bins}
  '';

  meta = with lib; {
    description = "System container image builder for LXC and LXD";
    homepage = "https://github.com/lxc/distrobuilder";
    license = licenses.asl20;
    maintainers = with maintainers; [ megheaiulian ];
    platforms = platforms.linux;
    mainProgram = "distrobuilder";
  };
}
