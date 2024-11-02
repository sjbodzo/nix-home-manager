{ config, lib, pkgs, ... }:
let
  cfg = config.programs.t-doomemacs;
  emacs = if pkgs.stdenv.isDarwin then
    pkgs.emacs29.overrideAttrs (old: {
      # inspiration https://github.com/noctuid/dotfiles/blob/30f615d0a8aed54cb21c9a55fa9c50e5a6298e80/nix/overlays/emacs.nix
      patches = (old.patches or [ ]) ++ [
        # fix os window role so that yabai can pick up emacs
        (pkgs.fetchpatch {
          url =
            "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/fix-window-role.patch";
          sha256 = "+z/KfsBm1lvZTZNiMbxzXQGRTjkCFO4QPlEK35upjsE=";
        })
        (pkgs.fetchpatch {
          url =
            "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-29/round-undecorated-frame.patch";
          sha256 = "uYIxNTyfbprx5mCqMNFVrBcLeo+8e21qmBE3lpcnd+4=";
        })
        # prevent cocoa app refocus after emacs is hidden or quit
        (pkgs.fetchpatch {
          url =
            "https://raw.githubusercontent.com/d12frosted/homebrew-emacs-plus/master/patches/emacs-28/no-frame-refocus-cocoa.patch";
          sha256 = "QLGplGoRpM4qgrIAJIbVJJsa4xj34axwT3LiWt++j/c=";
        })
      ];
    })
  else
    pkgs.emacs29-pgtk;
  treesit = (pkgs.emacsPackagesFor emacs).treesit-grammars.with-all-grammars;
in {

  options.programs.t-doomemacs.enable =
    lib.mkEnableOption "Enable doom emacs configuration.";

  config = lib.mkIf cfg.enable {

    programs.emacs = {
      enable = true;
      package = emacs;
      extraPackages = epkgs: [
        epkgs.vterm
        pkgs.mu # sic
        epkgs.mu4e
      ];
    };

    xdg.enable = true;
    home = {
      packages = with pkgs; [
        # mu4e+mbsync
        mu
        isync
        msmtp

        #webp support
        libwebp

        # emacs lsp
        nil # nix lsp https://github.com/oxalica/nil

        # emacs deps
        nodejs_20
        nodePackages.prettier
        nodePackages.bash-language-server
        nodePackages.yaml-language-server
        nodePackages.ts-node
        nodePackages.typescript
        nodePackages.typescript-language-server
        shellcheck

        babashka
      ];
      # put doom and custom .doom.d/bin/ on path
      sessionPath = [
        "${config.xdg.configHome}/emacs/bin"
        "${config.home.homeDirectory}/.doom.d/bin"
      ];
      sessionVariables = {
        # where doom is
        DOOMDIR = "${config.xdg.configHome}/doom.d";
        # where doom writes cache etc
        DOOMLOCALDIR = "${config.xdg.configHome}/doom-local";
        # where doom writes one more file
        DOOMPROFILELOADFILE =
          "${config.xdg.configHome}/doom-local/cache/profile-load.el";
      };
    };
    xdg.configFile = {
      # tree-sitter subdirectory of the directory specified by user-emacs-directory
      "doom-local/cache/tree-sitter".source = "${treesit}/lib";
      # git clone git@github.com:torgeir/.emacs.d.git ~/.doom.d
      "doom.d".source = config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.doom.d";
      "emacs" = {
        source = builtins.fetchGit {
          url = "https://github.com/hlissner/doom-emacs";
          rev = "97c0dcc2c328fcc791333e149418c26096043758";
        };
        # rev bumps will make doom sync run
        onChange = "${pkgs.writeShellScript "doom-change" ''
          # where your .doom.d files go
          export DOOMDIR="${config.home.sessionVariables.DOOMDIR}"

          # where doom will write to
          export DOOMLOCALDIR="${config.home.sessionVariables.DOOMLOCALDIR}"

          # https://github.com/doomemacs/doomemacs/issues/6794
          export DOOMPROFILELOADFILE="${config.home.sessionVariables.DOOMPROFILELOADFILE}"

          # cannot find git, cannot find emacs
          export PATH="$PATH:/run/current-system/sw/bin"
          export PATH="$PATH:/etc/profiles/per-user/torgeir/bin"

          if command -v emacs; then
            # not already installed
            if [ ! -d "$DOOMLOCALDIR" ]; then
              # having the env generated also prevents doom install from asking y/n on stdin,
              # also bring ssh socket
              ${config.xdg.configHome}/emacs/bin/doom env -a ^SSH_ -a ^GPG
              echo "doom-change :: Doom not installed: run doom install. ::"
            else
              echo "doom-change :: Doom already present: upgrade packages with doom sync -u ::"
              ${config.xdg.configHome}/emacs/bin/doom sync
            fi
          else
            echo "doom-change :: No emacs on path. ::"
          fi

        ''}";
      };
    };
  };
}