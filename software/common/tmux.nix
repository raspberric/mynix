{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    plugins = [pkgs.tmuxPlugins.yank];
    extraConfig = ''
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -i -sel clipboard"
      bind-key -n M-C-h swap-window -t -1\; select-window -t -1
      bind-key -n M-C-l swap-window -t +1\; select-window -t +1
    '';
  };
}
