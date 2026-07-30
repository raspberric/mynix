{pkgs}: let
  ghosttyConfig = ''
    # Font configuration
    # font-family = CaskaydiaMono Nerd Font
    # font-size = 9

    # Window settings
    window-padding-x = 4
    window-padding-y = 4
    window-decoration = false
    background-opacity = 0.98

    # Terminal settings
    term = xterm-256color

    # Keybindings
    keybind = f11=toggle_fullscreen

    # Follow system appearance using Ghostty's bundled Tokyo Night themes.
    theme = light:TokyoNight Day,dark:TokyoNight
  '';

  ghosttyIcon = pkgs.fetchurl {
    url = "https://github.com/ghostty-org/ghostty/blob/main/images/icons/icon_256.png?raw=true";
    sha256 = "sha256-KGGKqKHiOHbF7gX3a5NjV8O9dA40RprB05qjitUNKNg=";
  };

  configFile = pkgs.writeText "ghostty.config" ghosttyConfig;

  ghosttyWrapper = pkgs.writeShellApplication {
    name = "ghostty";
    runtimeInputs = [
      pkgs.ghostty
    ];
    text = ''
      exec ${pkgs.ghostty}/bin/ghostty --config-file=${configFile} "$@"
    '';
    meta = pkgs.ghostty.meta;
  };

  desktopFile = pkgs.makeDesktopItem {
    name = "com.mitchellh.ghostty";
    desktopName = "Ghostty";
    exec = "${ghosttyWrapper}/bin/ghostty";
    icon = ghosttyIcon;
    startupWMClass = "com.mitchellh.ghostty";
    categories = ["Utility" "TerminalEmulator"];
    comment = "Terminal emulator with custom theme";
  };
in
  pkgs.symlinkJoin {
    name = "ghostty-themed";
    paths = [ghosttyWrapper desktopFile];

    meta = pkgs.ghostty.meta;
  }
