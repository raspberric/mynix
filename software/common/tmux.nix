{pkgs, ...}: let
  tmuxConfigContent = pkgs.writeText "tmux.conf" ''
    setw -g mode-keys vi

    # copy tmux-yank contents to clipboard
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -i -sel clipboard"
    run-shell "tmux-yank"
    # move windows left and right
    bind-key -n M-C-h swap-window -t -1\; select-window -t -1
    bind-key -n M-C-l swap-window -t +1\; select-window -t +1
  '';
in
  pkgs.writeShellApplication {
    name = "tmux";
    runtimeInputs = [
      pkgs.tmux
      pkgs.tmuxPlugins.yank
    ];
    text = ''
      exec ${pkgs.tmux}/bin/tmux -f "${tmuxConfigContent}" "$@"
    '';

    meta = pkgs.tmux.meta;
  }
