{pkgs, ...}: let
  tmuxConfigContent = pkgs.writeTextFile {
    name = "tmux.conf";
    text = ''
      setw -g mode-keys vi

      # copy tmux-yank contents to clipboard
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "xclip -i -sel clipboard"

      run-shell ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/resurrect.tmux
      run-shell ${pkgs.tmuxPlugins.copy-toolkit}/share/tmux-plugins/copy-toolkit/copytk.tmux
      # move windows left and right
      bind-key -n M-C-h swap-window -t -1\; select-window -t -1
      bind-key -n M-C-l swap-window -t +1\; select-window -t +1

      # join windows
      bind-key j choose-window -F "#{window_index}: #{window_name}" "join-pane -h -s %%"
      bind-key J choose-window -F "#{window_index}: #{window_name}" "join-pane -v -s %%"

      # open a new window in cwd
      bind-key C new-window -c "#{pane_current_path}"
    '';
  };
in
  pkgs.writeShellApplication {
    name = "tmux";
    runtimeInputs = [
      pkgs.tmux
      pkgs.tmuxPlugins.resurrect
      pkgs.tmuxPlugins.copy-toolkit
    ];
    text = ''
      exec ${pkgs.tmux}/bin/tmux -f "${tmuxConfigContent}" "$@"
    '';

    meta = pkgs.tmux.meta;
  }
