{pkgs}:
pkgs.buildNpmPackage {
  pname = "nx";
  version = "22.3.1";
  src = ./.;
  npmDepsHash = "sha256-bF4lcaeBW0E4YPkqDsIOZCG3jvlOGVDTdiZ4oN4vgC8=";
  dontNpmBuild = true;

  postInstall = ''
    mkdir -p $out/bin
    ln -s $out/lib/node_modules/nx-wrapper/node_modules/.bin/nx $out/bin/nx
  '';
}
