{pkgs, ...}:
pkgs.writeShellApplication {
  name = "vps-facts";
  runtimeInputs = [
    pkgs.coreutils
    pkgs.openssh
  ];
  text =
    builtins.replaceStrings
    ["@remoteScript@"]
    [(toString ./vps-facts-remote.sh)]
    (builtins.readFile ./vps-facts.sh);
}
