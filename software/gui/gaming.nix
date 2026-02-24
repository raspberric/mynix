{pkgs, ...}: 
let
  ds-beamng = pkgs.writeShellApplication {
    name = "ds-beamng";
    runtimeInputs = [pkgs.dualsensectl];
    text = ''
      dualsensectl trigger left feedback-raw 0 0 0 4 4 4 8 8 8 8
      dualsensectl trigger right feedback-raw 2 2 2 3 3 3 4 4 5 5
    '';
  };
in
{
  programs = {
    steam.enable = true;
  };

  environment.systemPackages = [
    ds-beamng
  ];
}
