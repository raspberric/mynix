{
  pkgs,
  vimFlavor,
  ...
}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    go
    vimFlavor
  ];

  shellHook = ''
    # Ensure GOPATH is set within the shell context
    export GOPATH="$HOME/go"

    # Prepend the Go bin directory to your PATH
    export PATH="$GOPATH/bin:$PATH"

    echo "Go environment initialized: \$GOPATH/bin added to PATH"
  '';
}
