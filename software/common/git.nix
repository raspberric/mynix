{...}: {
  programs.git = {
    enable = true;
    config = {
      user.name = "Raspberric";
      user.email = "nikolamalinovic42@gmail.com";
      core.editor = "nvim";
      merge = {
        ff = false;
      };
    };
  };
}
