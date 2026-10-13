{pkgs, ...}:
# The laptop's srb-id service registers this module at boot.
pkgs.callPackage (
  {
    lib,
    stdenv,
    fetchFromGitHub,
    fetchurl,
    zig_0_15,
    pkg-config,
    pcsclite,
    nssTools,
    coreutils,
    makeWrapper,
  }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "srb-id-pkcs11";
      version = "0.4.0";

      src = fetchFromGitHub {
        owner = "ubavic";
        repo = "srb-id-pkcs11";
        # Update this to use a newer version
        rev = "48153cf31b4ed0138a74770597c012d9056bd19d";
        # Then you have to put sha256 = ''; here and nix will tell you the correct hash when you run the derivation
        sha256 = "0hsv4qaa0nw0xyya1whksi3a1hawxjf6kwq99vg4rwzc40zdlh5j";
      };

      nativeBuildInputs = [
        zig_0_15.hook
        pkg-config
        makeWrapper
      ];

      buildInputs = [
        pcsclite
      ];

      # Same goes for the hashes below - if you want a newer version you have to update the urls,
      # make hashes empty like so sha256 = ''; and then put the right ones when nix complains
      preBuild = ''
        mkdir -p include
        cp ${fetchurl {
          url = "https://docs.oasis-open.org/pkcs11/pkcs11-base/v2.40/errata01/os/include/pkcs11-v2.40/pkcs11.h";
          sha256 = "0m20vzpwpd7v2kvjgbrbr7rbkpib7mphs1qkk6ivca53x8damdwb";
        }} include/pkcs11.h
        cp ${fetchurl {
          url = "https://docs.oasis-open.org/pkcs11/pkcs11-base/v2.40/errata01/os/include/pkcs11-v2.40/pkcs11f.h";
          sha256 = "0mv01hhis89g6y51jdrzkfna56q47gnz6xqkqzcxmjdz738dlnm8";
        }} include/pkcs11f.h
        cp ${fetchurl {
          url = "https://docs.oasis-open.org/pkcs11/pkcs11-base/v2.40/errata01/os/include/pkcs11-v2.40/pkcs11t.h";
          sha256 = "18kikrs69r8zkglc9bsk65n0a4cxdfq29kcjji6jpw93dmmp6n2v";
        }} include/pkcs11t.h

        ln -s ${zig_0_15.fetchDeps {
          inherit (finalAttrs) src pname version;
          hash = "sha256-eOKt1yea/zt5OtP0sNq7kCysQLpUwoEhqr188GAskxs=";
        }} $ZIG_GLOBAL_CACHE_DIR/p
      '';

      postInstall = ''
        # Create a helper script to register the PKCS#11 module in Chrome's NSS database
        mkdir -p $out/bin

        cat > $out/bin/register-srb-id-chrome << 'SCRIPT'
        #!/usr/bin/env bash
        set -euo pipefail

        NSSDB="$HOME/.pki/nssdb"
        MODULE_NAME="Srb Id PKCS11"
        SO_PATH="@out@/lib/libsrb-id-pkcs11.so"

        echo "Setting up Serbian ID PKCS#11 module for Chrome/Chromium..."

        mkdir -p "$NSSDB"
        if [ ! -f "$NSSDB/cert9.db" ]; then
            echo "Creating NSS database at $NSSDB..."
            modutil -force -create -dbdir sql:"$NSSDB"
        fi

        # Unlike -add, -rawadd can persist the registration even if module
        # initialization fails (pcscd denies access before a desktop login).
        # It also replaces an existing entry with the same name.
        echo "Registering module..."
        modutil -force -dbdir sql:"$NSSDB" \
          -rawadd "name=\"$MODULE_NAME\" library=\"$SO_PATH\""

        echo "Success! The Serbian ID module has been registered."
        echo "Please completely restart Chrome/Chromium for the changes to take effect."
        SCRIPT

        # Replace @out@ with the actual nix store path
        substituteInPlace $out/bin/register-srb-id-chrome \
          --replace-warn "@out@" "$out"

        chmod +x $out/bin/register-srb-id-chrome

        # Include runtime tools for non-interactive systemd execution.
        wrapProgram $out/bin/register-srb-id-chrome \
          --prefix PATH : ${lib.makeBinPath [nssTools coreutils]}
      '';

      meta = with lib; {
        description = "PKCS#11 module for Serbian ID cards";
        homepage = "https://github.com/ubavic/srb-id-pkcs11";
        license = licenses.unlicense;
        platforms = platforms.linux;
        mainProgram = "register-srb-id-chrome";
      };
    })
) {}
