{
  config,
  lib,
  pkgs,
  vpsInstance,
  ...
}: let
  dataDir = "/var/lib/open-design";
  codexHome = "${dataDir}/agents/codex";
  openCodeRoot = "${dataDir}/agents/opencode";
  publicOrigin = "https://${vpsInstance.tailscaleDnsName}";
  tailscale = lib.getExe config.services.tailscale.package;

  codexConfig = pkgs.writeText "open-design-codex-config.toml" ''
    cli_auth_credentials_store = "file"
  '';

  openDesignCodex = pkgs.writeShellApplication {
    name = "open-design-codex";
    runtimeInputs = [pkgs.coreutils pkgs.util-linux];
    text = ''
      exec runuser -u open-design -- env \
        HOME=${lib.escapeShellArg dataDir} \
        CODEX_HOME=${lib.escapeShellArg codexHome} \
        ${lib.getExe pkgs.codex} "$@"
    '';
  };

  openDesignOpenCode = pkgs.writeShellApplication {
    name = "open-design-opencode";
    runtimeInputs = [pkgs.coreutils pkgs.util-linux];
    text = ''
      exec runuser -u open-design -- env \
        HOME=${lib.escapeShellArg dataDir} \
        XDG_CONFIG_HOME=${lib.escapeShellArg "${openCodeRoot}/config"} \
        XDG_DATA_HOME=${lib.escapeShellArg "${openCodeRoot}/data"} \
        XDG_CACHE_HOME=${lib.escapeShellArg "${openCodeRoot}/cache"} \
        ${lib.getExe pkgs.opencode} "$@"
    '';
  };
in {
  assertions = [
    {
      assertion = !lib.hasInfix "REPLACE_WITH" vpsInstance.tailscaleDnsName;
      message = "Replace the Tailscale hostname placeholder in machines/vps/instance.nix.";
    }
    {
      assertion = builtins.match "^[A-Za-z0-9.-]+[.]ts[.]net$" vpsInstance.tailscaleDnsName != null;
      message = "Set tailscaleDnsName to the VPS MagicDNS HTTPS hostname ending in .ts.net.";
    }
  ];

  services.open-design = {
    enable = true;
    autoStart = true;
    openFirewall = false;

    port = 7457;
    inherit dataDir;

    webFrontend = {
      enable = true;
      host = "127.0.0.1";
      port = 5174;
      allowedOrigins = [publicOrigin];
    };

    extraEnv = {
      HOME = dataDir;

      CODEX_BIN = lib.getExe pkgs.codex;
      CODEX_HOME = codexHome;

      OPENCODE_BIN = lib.getExe pkgs.opencode;
      XDG_CONFIG_HOME = "${openCodeRoot}/config";
      XDG_DATA_HOME = "${openCodeRoot}/data";
      XDG_CACHE_HOME = "${openCodeRoot}/cache";

      OD_PUBLIC_BASE_URL = publicOrigin;
    };
  };

  systemd.tmpfiles.rules = [
    "d ${dataDir}/agents 0700 open-design open-design - -"
    "d ${codexHome} 0700 open-design open-design - -"
    "L+ ${codexHome}/config.toml - - - - ${codexConfig}"
    "d ${openCodeRoot} 0700 open-design open-design - -"
    "d ${openCodeRoot}/config 0700 open-design open-design - -"
    "d ${openCodeRoot}/data 0700 open-design open-design - -"
    "d ${openCodeRoot}/cache 0700 open-design open-design - -"
  ];

  systemd.services.open-design-web = {
    requires = ["open-design.service"];
    after = ["open-design.service"];
  };

  systemd.services.open-design-tailscale-serve = {
    description = "Expose Open Design through private Tailscale Serve";
    wantedBy = ["multi-user.target"];
    requires = ["tailscale-online.target" "open-design-web.service"];
    after = ["tailscale-online.target" "open-design-web.service"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      Restart = "on-failure";
      RestartSec = 5;
      ExecStart = "${tailscale} serve --bg --yes --https=443 --set-path=/ http://127.0.0.1:5174";
      ExecStop = "-${tailscale} serve --yes --https=443 --set-path=/ off";
    };
  };

  environment.systemPackages = [openDesignCodex openDesignOpenCode];
}
