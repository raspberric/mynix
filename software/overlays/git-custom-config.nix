final: prev: {
  # Define the content of your custom .gitconfig file
  gitConfigCustom = prev.writeText "gitconfig-custom" ''
    [user]
      name = "Raspberric"
      email = "nikolamalinovic42@gmail.com"
    [core]
      editor = nvim
    [merge]
      ff = false
  '';

  # Override the 'git' package itself
  git = prev.writeShellApplication {
    name = "git"; # Keep the name as 'git'
    runtimeInputs = [
      prev.git # Reference the *original* git package from 'prev'
    ];
    text = ''
      # Set the GIT_CONFIG_GLOBAL environment variable to your custom config
      export GIT_CONFIG_GLOBAL="${prev.gitConfigCustom}"
      # Execute the original git command with all arguments
      exec ${prev.git}/bin/git "$@"
    '';

    # Inherit metadata from the original git package
    meta = prev.git.meta // {
      description = "Git with custom user configuration (overridden)";
    };
  };
}