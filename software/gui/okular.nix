{pkgs, ...}: let
  okularWrapper = pkgs.writeShellApplication {
    name = "okular-signed";

    # Packages to be added to the script's PATH
    runtimeInputs = with pkgs; [
      kdePackages.okular
      gtk3
      gsettings-desktop-schemas
    ];

    text = ''
      # Export the GSettings schemas so the FileChooser doesn't crash
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:$XDG_DATA_DIRS"

      # Match the GNOME launcher and pass through document arguments.
      exec okular --desktopfile okular-signed "$@"
    '';
  };

  desktopFile = pkgs.makeDesktopItem {
    name = "okular-signed";
    desktopName = "Okular Signed";
    genericName = "Document Viewer";
    comment = "View and sign PDF documents";
    exec = "${okularWrapper}/bin/okular-signed %U";
    icon = "${pkgs.kdePackages.okular}/share/icons/hicolor/128x128/apps/okular.png";
    terminal = false;
    categories = ["Office" "Viewer"];
    mimeTypes = ["application/pdf"];
    keywords = ["PDF" "Signature"];
    startupNotify = true;
  };
in
  pkgs.symlinkJoin {
    name = "okular-signed";
    paths = [okularWrapper desktopFile];
    meta.mainProgram = "okular-signed";
  }
