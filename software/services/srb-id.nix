{
  config,
  pkgs,
  ...
}: {
  systemd.services.srb-id = {
    description = "Register the Serbian ID PKCS#11 module for Chrome/Chromium";
    wantedBy = ["multi-user.target"];
    before = ["display-manager.service"];
    unitConfig.RequiresMountsFor = [config.users.users.xpo.home];
    environment.HOME = config.users.users.xpo.home;
    serviceConfig = {
      Type = "oneshot";
      User = "xpo";
      RemainAfterExit = true;
      ExecStart = "${import ../common/srb-id-pkcs11-chrome.nix {inherit pkgs;}}/bin/register-srb-id-chrome";
    };
  };
}
