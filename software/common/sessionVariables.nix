{...}: {
  environment.sessionVariables = rec {
    EDITOR = "nvim";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    NODE_PATH = "${NPM_CONFIG_PREFIX}/lib/node_modules";

    # Use a list for PATH; NixOS will automatically join it with ':'
    # and merge it with the existing system PATH
    PATH = ["${NPM_CONFIG_PREFIX}/bin"];
  };
}
