{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "ben";
  home.homeDirectory = "/home/ben";
  home.stateVersion = "26.05";
  programs.zsh = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/yggdrasil-conf#Yggdrasil";
    };
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    initContent = ''
      if command -v grc &> /dev/null; then
        source ${pkgs.grc}/etc/grc.zsh
      fi
      setopt AUTO_CD
      setopt CORRECT
    '';
  };
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "$directory$git_branch$git_status$nix_shell$character";

      character = {
        success_symbol = "[➜](bold #9ece6a)"; # verde
        error_symbol = "[➜](bold #f7768e)"; # rojo
      };

      directory = {
        truncation_length = 3;
        style = "bold #7aa2f7"; # azul
      };

      git_branch = {
        symbol = " ";
        style = "bold #bb9af7"; # púrpura
      };

      git_status = {
        style = "bold #e0af68"; # amarillo
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold #7dcfff"; # cyan
        format = "via [$symbol$state]($style) ";
      };
    };
  };
  home.packages =
    with pkgs;
    [
      nil
      nixpkgs-fmt
      alacritty
      zoxide
      grc
      uv
      btop
      tree
      phpPackages.composer

      # XFCE Theming
      qogir-theme
      qogir-icon-theme
      xfce4-whiskermenu-plugin
      conky

    ]
    ++ [
      inputs.nvim-config.packages.x86_64-linux.default
    ];
  programs.git = {
    enable = true;
    settings = {
      user.name = "benjamin ely";
      user.email = "benjamin.ely07@gmail.com";
      init.defaultBranch = "main";
    };
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "tmux-256color";
    historyLimit = 10000;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator # navega entre panes de tmux y splits de nvim con Ctrl+hjkl, sin distinguir cuál es cuál
      yank # mejora el copiado al portapapeles del sistema
      {
        plugin = resurrect; # guarda/restaura sesiones completas
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = continuum; # auto-guarda sesiones cada cierto tiempo, usa resurrect por debajo
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
      {
        plugin = catppuccin; # mismo tema que ya usas en nvim
        extraConfig = ''
          set -g @catppuccin_flavor "mocha"
        '';
      }
    ];
    extraConfig = ''
      # divide paneles de forma más intuitiva
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      # recargar config con prefix + r
      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
    '';
  };
}
