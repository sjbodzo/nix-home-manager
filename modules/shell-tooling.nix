{ dotfiles, config, lib, pkgs, ... }:

let cfg = config.programs.t-shell-tooling;
in {

  options.programs.t-shell-tooling.enable =
    lib.mkEnableOption "Enable useful shell tooling";

  config = lib.mkIf cfg.enable {
    programs.jq = { enable = true; };
    programs.fzf = {
        enable = true;
        package = pkgs.unstable.fzf;
    };
    programs.go = { enable = true; };
    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fonts.fontconfig.enable = true;

    home.packages = with pkgs;
      [
        (nerdfonts.override { fonts = [ "Iosevka" "IosevkaTerm" ]; })
        (ripgrep.override { withPCRE2 = true; })
	    starship
        eza
        fd

        bat
        gawk
        htop
        btop
        watch
        _1password
        _1password-gui
        git
        entr
        magic-wormhole-rs
        yazi

        nil
        nixfmt

        curl
        jq
        yq
        just

        fnm
        python3
        rustup

        tree
        ripgrep

        kubectl
        kubie
        krew
      ];

    home.file.".config/btop".source = dotfiles + "/.config/btop";
    home.file.".config/bat".source = dotfiles + "/.config/bat";
    home.file.".config/starship.toml".source = dotfiles + "/.config/starship.toml";
    home.file.".config/wezterm/wezterm.lua".source = dotfiles + "/.config/wezterm/wezterm.lua";

    # zsh
    home.file.".zshrc".source = dotfiles + "/.zshrc";
    home.file.".zshenv".source = dotfiles + "/.zshenv";
    home.file.".zprofile".source = dotfiles + "/.zprofile";
    home.file.".zplugin" = {
        recursive = true;
        source = dotfiles + "/.config/zsh/.zplugin";
        target = "/.config/zsh/.zplugin";
    };
    home.file.".zfunc" = {
        recursive = true;
        source = dotfiles + "/.config/zsh/.zfunc";
        target = "/.config/zsh/.zfunc";
    };
  };
}
