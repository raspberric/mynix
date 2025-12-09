{pkgs, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "google-chrome"
      "zoom-us"
    ];

  environment.systemPackages = with pkgs; [
    google-chrome
  ];
  programs = {
    zoom-us.enable = true;
  };

  # TODO: editor = neovim
  # add dev.nix add opencode
  # set max generations to 5
}
