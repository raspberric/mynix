{pkgs, ...}: let
  ds-beamng = pkgs.writeShellApplication {
    name = "ds-beamng";
    runtimeInputs = [pkgs.dualsensectl];
    text = ''
      dualsensectl trigger left feedback-raw 0 0 0 3 3 3 6 6 8 8
      dualsensectl trigger right feedback-raw 0 0 0 2 2 2 4 4 4 4
    '';
  };
in {
  programs = {
    steam.enable = true;
  };

  environment.systemPackages = [
    ds-beamng
  ];
}
