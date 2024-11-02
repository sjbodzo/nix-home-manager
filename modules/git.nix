{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.git;
in {
  config = lib.mkIf cfg.enable {
    programs.git = {
      userName = "sjbodzo";
      userEmail = "jess@sjbodzo.com";
      aliases = { gg = "log --all --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"; }; 
    };

    home.packages = with pkgs; [ delta difftastic ];
    #home.file.".gitconfig".source = dotfiles + "/gitconfig";
  };
}
