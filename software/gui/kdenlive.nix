{pkgs, ...}:
pkgs.symlinkJoin {
  name = "kdenlive-configured";
  paths = [pkgs.kdePackages.kdenlive];
  nativeBuildInputs = [pkgs.makeWrapper];

  postBuild = ''
    # Qt's GTK file dialog needs these schemas on GNOME to avoid aborting on Save As.
    wrapProgram "$out/bin/kdenlive" \
      --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
  '';

  meta = pkgs.kdePackages.kdenlive.meta;
}
