{pkgs}: let
  tokynightTheme = ''
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

    # Color scheme from omarchy theme
    background = 1a1b26
    foreground = a9b1d6

    # Normal colors
    palette = 0=#32344a
    palette = 1=#f7768e
    palette = 2=#9ece6a
    palette = 3=#e0af68
    palette = 4=#7aa2f7
    palette = 5=#ad8ee6
    palette = 6=#449dab
    palette = 7=#787c99

    # Bright colors
    palette = 8=#444b6a
    palette = 9=#ff7a93
    palette = 10=#b9f27c
    palette = 11=#ff9e64
    palette = 12=#7da6ff
    palette = 13=#bb9af7
    palette = 14=#0db9d7
    palette = 15=#acb0d0

    # Selection color
    selection-background = 7aa2f7
  '';

  ghosttyIcon = pkgs.fetchurl {
    url = "https://github.com/ghostty-org/ghostty/blob/main/images/icons/icon_256.png?raw=true";
    sha256 = "sha256-KGGKqKHiOHbF7gX3a5NjV8O9dA40RprB05qjitUNKNg=";
  };

  configFile = pkgs.writeText "ghostty.config" tokynightTheme;

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
