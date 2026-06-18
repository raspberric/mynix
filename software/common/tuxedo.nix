{pkgs ? import <nixpkgs> {}}: let
  tuxedoBase = pkgs.rustPlatform.buildRustPackage rec {
    pname = "tuxedo-base";
    version = "2026.6.2";

    # Fetch the source code directly from GitHub
    src = pkgs.fetchFromGitHub {
      owner = "webstonehq";
      repo = "tuxedo";
      rev = "v${version}"; # Can be a tag, commit hash, or branch
      hash = "sha256-0ulyr7AbB6KZbAAvxc/s0NJTPBYS42UCbEXYREJTWMo=";
    };

    # Nix uses this hash to lock and cache the Cargo dependencies safely
    cargoHash = "sha256-Sd3O/bw3/FZeas2eWAvSV3HWcDQg8Cla2hagWVYRKsc=";

    doCheck = false;
  };
in
  pkgs.writeShellApplication {
    name = "tuxedo";
    runtimeInputs = [tuxedoBase];
    text = ''
      export TODO_FILE="/home/xpo/Projecsts/todo.txt"
      exec tuxedo "$@"
    '';
  }
