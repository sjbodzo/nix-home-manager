{ pkgs, lib, ... }:

{
  imports = [
    ./nvim.nix
    ./git.nix
    ./shell-tooling.nix
    ./tmux.nix
  ];

  programs.zsh.enable = true;
  programs.t-shell-tooling.enable = true;
  programs.neovim.enable = true;
}
