{pkgs, ...}: {
  services.gitea = {
    enable = true;
    package = pkgs.gitea; # Uses the stable Gitea package

    # Automatically creates a 'gitea' user and group to run the service securely
    user = "gitea";
    stateDir = "/var/lib/gitea";

    # Database configuration (SQLite is perfect for a single-user private VPS)
    database = {
      type = "sqlite3";
      path = "/var/lib/gitea/data/gitea.db";
    };

    # Application settings
    settings = {
      server = {
        ROOT_URL = "http://localhost:3000/"; # Change to your domain if using a reverse proxy (e.g., https://git.example.com)
        HTTP_PORT = 3000;
        DOMAIN = "localhost";
      };

      # Privacy tweaks for a private repository server
      service = {
        DISABLE_REGISTRATION = true; # Prevent random internet users from registering
        REQUIRE_SIGNIN_VIEW = true; # Hide repositories entirely from anonymous users
        ENABLE_CAPTCHA = false; # Not needed if registration is closed
      };

      security = {
        INSTALL_LOCK = true; # Lock the web-based installer for safety
      };
    };
  };
}
