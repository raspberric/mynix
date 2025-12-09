{pkgs, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
      "heroic" # Assuming heroic is also unfree and you want to allow it
    ];

  environment.systemPackages = [
    pkgs.discord
    pkgs.heroic
  ];

  programs.steam.enable = true;
}
