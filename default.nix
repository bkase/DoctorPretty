with import <nixpkgs> {};
pkgs.stdenv.mkDerivation rec {
  name = "DoctorPretty";
  # get deps
  buildInputs = [ git swift ];
  src = ./.;

  configurePhase = ''
    # Make clones via https work
    export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
  '';

  buildPhase = ''
    swift build
  '';

  # test
  doCheck = true;
  checkPhase = ''
    SWIFTPM_TEST_DoctorPretty=YES swift test
  '';

  installPhase = ''
    touch $out
  '';
}

