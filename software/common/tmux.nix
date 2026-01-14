{pkgs, ...}: let
  tmuxConfigContent = builtins.toFile "tmux.conf" ''
    setw -g mode-keys vi

    # copy tmux-yank contents to clipboard
    bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -i -sel clipboard"
    run-shell "tmux-yank"
    run-shell "tmux-resurrect"
    # move windows left and right
    bind-key -n M-C-h swap-window -t -1\; select-window -t -1
    bind-key -n M-C-l swap-window -t +1\; select-window -t +1
    # join windows
    bind-key j choose-window -F "#{window_index}: #{window_name}" "join-pane -h -t %%"
    bind-key J choose-window -F "#{window_index}: #{window_name}" "join-pane -v -t %%"
  '';
in
  pkgs.writeShellApplication {
    name = "tmux";
    runtimeInputs = [
      pkgs.tmux
      pkgs.tmuxPlugins.yank
      pkgs.tmuxPlugins.resurrect
    ];
    text = ''
      exec ${pkgs.tmux}/bin/tmux -f "${tmuxConfigContent}" "$@"
    '';

    meta = pkgs.tmux.meta;
  }
