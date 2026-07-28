{
  pkgs,
  nixpkgs-esp-dev,
  vimFlavor,
  ...
}: let
  # Include ESP-IDF support using mirrexagon's flake.
  espPkgs = import nixpkgs-esp-dev.inputs.nixpkgs {
    system = pkgs.stdenv.hostPlatform.system;
    overlays = [ nixpkgs-esp-dev.overlays.default ];
    config = {
      permittedInsecurePackages = [
        "python3.13-ecdsa-0.19.1"
      ];
    };
  };

  # Use EEZ Studio AppImage since the flake is currently broken
  eezStudio = pkgs.appimageTools.wrapType2 rec {
    pname = "eez-studio";
    version = "0.26.2";
    src = pkgs.fetchurl {
      url = "https://github.com/eez-open/studio/releases/download/v${version}/EEZ-Studio-${version}.AppImage";
      sha256 = "1aw40svv0ivna5ddaycmhzch6vwrcwvwjql1fbndrqnpg1k49awm";
    };
  };
in
pkgs.mkShell {
  buildInputs = [
    vimFlavor
    eezStudio
    pkgs.cmake
    pkgs.ninja
    
    # ESP-IDF toolchain for esp32s3
    espPkgs.esp-idf-full
  ];

  shellHook = ''
    echo "ESP32-S3 / C++ dev shell initialized."
    echo "Commands available: idf.py, eez-studio"
  '';
}
