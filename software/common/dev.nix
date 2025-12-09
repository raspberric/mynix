{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    tldr
    nodejs_24
    pnpm
    xclip
    ripgrep
  ];
}
