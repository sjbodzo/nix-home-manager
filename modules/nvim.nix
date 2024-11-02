{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.neovim;
in {
  config = lib.mkIf cfg.enable {
    programs.neovim = {
      defaultEditor= true;
      vimAlias = true;
    };

    xdg.configFile.nvim = {
      source = dotfiles + "/.config/nvim";
      recursive = true;
    };
  };
}
