{
  description = "Ghostty config flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };

  outputs = {nixpkgs, ...}: {
    overlays.default = final: prev: {
      ghosttyDesktopItem = prev.makeDesktopItem {
        name = "ghostty";
        genericName = "terminal emulator";
        desktopName = "ghostty (themed)";
        comment = prev.ghostty.meta.description;
        exec = "${prev.ghostty}/bin/ghostty --theme=tokyonight-storm";
        icon = "utilities-terminal";
        categories = ["Utility"];
      };
    };
  };
}
