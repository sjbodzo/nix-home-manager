{ dotfiles, config, lib, pkgs, ... }:

let
    cfg = config.programs.t-shell-tooling;
    gdk = pkgs.google-cloud-sdk.withExtraComponents( with pkgs.google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
    ]);
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
      package = pkgs.unstable.direnv;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fonts.fontconfig.enable = true;

    home.packages = with pkgs;
      [
        (ripgrep.override { withPCRE2 = true; })
        nerd-fonts.jetbrains-mono
        nerd-fonts.zed-mono
        nerd-fonts.mononoki
        nerd-fonts.iosevka-term
        nerd-fonts.iosevka

	    starship
        eza
        zellij
        fd

        bat
        gawk
        htop
        btop
        watch
        gdk
        git
        entr
        magic-wormhole-rs
        deno
        yazi

        awscli2
        gdk

        pkgs.unstable.nh
        nil
        nixfmt-rfc-style

        curl
        jq
        yq-go
        just

        fnm
        mise
        python3
        rustup
        zig
        gopls

        cmake
        libiconv

        tree
        ripgrep

        skopeo
        kubectl
        krew
      ];

    home.file.".config/btop".source = dotfiles + "/.config/btop";
    home.file.".config/bat".source = dotfiles + "/.config/bat";
    home.file.".config/starship.toml".source = dotfiles + "/.config/starship.toml";
    home.file.".config/wezterm/wezterm.lua".source = dotfiles + "/.config/wezterm/wezterm.lua";

    # ghostty
    home.file.".config/ghostty/config".source = dotfiles + "/.config/ghostty/config";

    # zellij
    home.file.".config/zellij" = {
        recursive = true;
        source = dotfiles + "/.config/zellij";
        target = ".config/zellij";
    };

    # zsh
    home.file.".zshrc".source = dotfiles + "/.config/zsh/.zshrc";
    home.file.".zshenv".source = dotfiles + "/.config/zsh/.zshenv";
    home.file.".zprofile".source = dotfiles + "/.config/zsh/.zprofile";
    home.file.".zplugin" = {
        recursive = true;
        source = dotfiles + "/.config/zsh/.zplugin";
        target = ".config/zsh/.zplugin";
    };
    home.file.".zfunc" = {
        recursive = true;
        source = dotfiles + "/.config/zsh/.zfunc";
        target = ".config/zsh/.zfunc";
    };

    # jj
    home.file.".jjconfig.toml".source = dotfiles + "/.config/.jjconfig.toml";
  };
}
