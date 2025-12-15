{pkgs}: let
  ghosttyIcon = pkgs.fetchurl {
    url = "https://github.com/ghostty-org/ghostty/blob/main/images/icons/icon_256.png?raw=true";
    sha256 = "sha256-KGGKqKHiOHbF7gX3a5NjV8O9dA40RprB05qjitUNKNg="; 
  };

  ghosttyWrapper = pkgs.writeShellApplication {
    name = "ghostty";
    runtimeInputs = [
      pkgs.ghostty
    ];
    text = ''
      exec ${pkgs.ghostty}/bin/ghostty --theme=tokyonight-storm "$@"
    '';
    meta = pkgs.ghostty.meta;
  };

  desktopFile = pkgs.makeDesktopItem {
    name = "Ghostty";
    desktopName = "Ghostty";
    exec = "${ghosttyWrapper}/bin/ghostty";
    icon = ghosttyIcon;
    categories = ["Utility" "TerminalEmulator"];
    comment = "Terminal emulator with custom theme";
  };
in
  pkgs.symlinkJoin {
    name = "ghostty-themed";
    paths = [ghosttyWrapper desktopFile];

    meta = pkgs.ghostty.meta;
  }
