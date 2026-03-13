{pkgs}:
# run register-srb-id-chrome after to register the smartcard module to nss db
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
    makeWrapper,
  }:
    stdenv.mkDerivation (finalAttrs: {
      pname = "srb-id-pkcs11";
      version = "0.4.0"; # keeping 0.4.0 as it aligns with the version.zig in the repo right now

      src = fetchFromGitHub {
        owner = "ubavic";
        repo = "srb-id-pkcs11";
        rev = "48153cf31b4ed0138a74770597c012d9056bd19d";
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

        if [ ! -d "$NSSDB" ]; then
            echo "Creating NSS database directory at $NSSDB..."
            mkdir -p "$NSSDB"
            modutil -force -create -dbdir sql:"$NSSDB"
        fi

        # Check if module already exists
        if modutil -dbdir sql:"$NSSDB" -list | grep -q "$MODULE_NAME"; then
            echo "Module '$MODULE_NAME' is already registered. Removing old entry..."
            modutil -force -dbdir sql:"$NSSDB" -delete "$MODULE_NAME"
        fi

        echo "Registering module..."
        modutil -force -dbdir sql:"$NSSDB" -add "$MODULE_NAME" -libfile "$SO_PATH"

        echo "Success! The Serbian ID module has been registered."
        echo "Please completely restart Chrome/Chromium for the changes to take effect."
        SCRIPT

        # Replace @out@ with the actual nix store path
        substituteInPlace $out/bin/register-srb-id-chrome \
          --replace-warn "@out@" "$out"

        chmod +x $out/bin/register-srb-id-chrome

        # Ensure modutil is available when the script runs
        wrapProgram $out/bin/register-srb-id-chrome \
          --prefix PATH : ${lib.makeBinPath [nssTools]}
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
