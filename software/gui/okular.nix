{pkgs, ...}:
pkgs.writeShellApplication {
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

    # Run okular, passing through any arguments (like the PDF file path)
    exec okular "$@"
  '';
}
