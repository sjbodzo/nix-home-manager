{ pkgs, lib, ... }:

{
  imports = [
    ./emacs.nix
    ./nvim.nix
    ./git.nix
    ./shell-tooling.nix
    ./tmux.nix
  ];

  programs.zsh.enable = true;
  programs.t-shell-tooling.enable = true;
  programs.t-doomemacs.enable = true;
  programs.neovim.enable = true;
}
