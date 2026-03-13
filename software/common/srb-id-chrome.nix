{ pkgs }:

let
  srbIdPkcs11 = import ./srb-id-pkcs11.nix { inherit pkgs; };
  chrome = pkgs.google-chrome;
in
pkgs.writeShellScriptBin "chrome-smart-card" ''
  # We need to ensure pcscd is running if we are not on NixOS
  # This requires root privileges, so we check and warn the user.
  if ! pgrep -x "pcscd" > /dev/null; then
    echo "====================================================================="
    echo "⚠️  WARNING: Smartcard Service (pcscd) is not running!"
    echo "====================================================================="
    echo "Your smartcard reader will not be detected by Chrome."
    echo ""
    echo "If you are on NixOS, please add the following to your configuration.nix:"
    echo "  services.pcscd.enable = true;"
    echo ""
    echo "If you are using Nix on another Linux distribution (like Ubuntu), run:"
    echo "  sudo apt update && sudo apt install pcscd libccid"
    echo "  sudo systemctl start pcscd"
    echo "====================================================================="
    echo "Starting Chrome anyway, but smartcard authentication may fail."
    echo ""
    sleep 3
  fi

  # Set up an isolated NSS database specifically for this Chrome instance
  # This prevents conflicts with the system NSS database and ensures Chrome always sees the module.
  ISOLATED_NSSDB="$HOME/.pki/nssdb-srb-id"
  MODULE_NAME="Srb Id PKCS11"
  SO_PATH="${srbIdPkcs11}/lib/libsrb-id-pkcs11.so"

  if [ ! -d "$ISOLATED_NSSDB" ]; then
    echo "Creating isolated NSS database at $ISOLATED_NSSDB..."
    mkdir -p "$ISOLATED_NSSDB"
    ${pkgs.nssTools}/bin/modutil -force -create -dbdir sql:"$ISOLATED_NSSDB"
  fi

  # Register the module in the isolated database
  if ! ${pkgs.nssTools}/bin/modutil -dbdir sql:"$ISOLATED_NSSDB" -list | grep -q "$MODULE_NAME"; then
    echo "Registering Serbian ID module..."
    ${pkgs.nssTools}/bin/modutil -force -dbdir sql:"$ISOLATED_NSSDB" -add "$MODULE_NAME" -libfile "$SO_PATH"
  fi

  # Chrome on Linux expects the NSS database to be in $HOME/.pki/nssdb
  # To force it to read our custom DB without messing up the user's main environment,
  # we run Chrome with a customized HOME environment variable just for this process.
  
  ISOLATED_HOME="$HOME/.config/chrome-srb-id-env"
  mkdir -p "$ISOLATED_HOME/.pki"
  
  # Symlink our prepared NSS database into the isolated home's expected path
  if [ ! -L "$ISOLATED_HOME/.pki/nssdb" ]; then
    ln -sf "$ISOLATED_NSSDB" "$ISOLATED_HOME/.pki/nssdb"
  fi

  echo "Launching Chrome with Serbian ID Smartcard support..."
  
  # Launch Chrome pointing its HOME to our isolated environment
  HOME="$ISOLATED_HOME" exec ${chrome}/bin/google-chrome-stable \
    --user-data-dir="$ISOLATED_HOME/.config/google-chrome" \
    "$@"
''
