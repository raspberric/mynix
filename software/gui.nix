{pkgs, ...}: let
  ghosttyConfigured = import ./gui/ghostty.nix {inherit pkgs;};
  discordConfigured = import ./gui/discord.nix {inherit pkgs;};
  okularConfigured = import ./gui/okular.nix {inherit pkgs;};
in {
  apps = pkgs.symlinkJoin {
    name = "Gui applications";
    paths = with pkgs; [
      ghosttyConfigured
      okularConfigured
      discordConfigured
      inkscape
      google-chrome
    ];
  };
}
