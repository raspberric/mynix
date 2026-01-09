{pkgs}: let
  discordIcon = pkgs.fetchurl {
    url = "https://cdn-icons-png.flaticon.com/512/4945/4945973.png";
    sha256 = "StLiUJR2gl5nzitXRMv2r8rjwq+l06BXUT2467yW30k=";
  };

  discordConfigured = pkgs.discord.override {
    withOpenASAR = true;
    withVencord = true;
  };

  discordWrapper = pkgs.writeShellApplication {
    name = "discord";
    runtimeInputs = [
      discordConfigured
    ];
    text = ''
      exec ${discordConfigured}/bin/discord "$@"
    '';
    meta = discordConfigured.meta;
  };

  desktopFile = pkgs.makeDesktopItem {
    name = "discord";
    desktopName = "Discord";
    exec = "${discordWrapper}/bin/discord";
    icon = discordIcon;
    categories = ["Network" "InstantMessaging"];
    comment = "All-in-one voice and text chat for gamers that's free, secure, and works on both your desktop and phone.";
  };
in
  pkgs.symlinkJoin {
    name = "discord-custom";
    paths = [discordWrapper desktopFile];

    meta = discordConfigured.meta;
  }
