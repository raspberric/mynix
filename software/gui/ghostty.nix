{pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      ghosttyDesktopItem = prev.makeDesktopItem {
        name = "ghostty";
        genericName = "terminal emulator";
        desktopName = "ghostty (themed)";
        comment = prev.ghostty.meta.description;
        exec = "${prev.ghostty}/bin/ghostty --theme=tokyonight-storm";
        icon = "utilities-terminal";
        categories = ["Utility"];
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    ghostty
    ghosttyDesktopItem
  ];
}
