{...}: {
  environment.sessionVariables = rec {
    EDITOR = "nvim";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    NODE_PATH = "${NPM_CONFIG_PREFIX}/lib/node_modules";
  };

  # Use extraInit to extend PATH safely
  environment.extraInit = ''
    export PATH="$HOME/.npm-global/bin:$PATH"
  '';
}
