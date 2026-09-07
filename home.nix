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
        success_symbol = "[➜](bold #e8e7e3)";
        error_symbol = "[➜](bold #e67e80)";
      };

      directory = {
        truncation_length = 3;
        style = "bold #7fbbb3";
      };

      git_branch = {
        symbol = " ";
        style = "bold #d699b6";
      };

      git_status = {
        style = "bold #dbbc7f";
      };

      nix_shell = {
        symbol = "❄️ ";
        style = "bold #83c092";
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

      # Editors
      zed-editor
      helix

      # misc
      dmidecode

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
      vim-tmux-navigator
      yank

      {
        plugin = resurrect;
        extraConfig = ''
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }

      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '15'
        '';
      }
    ];

    extraConfig = ''
      # ─────────────────────────────────────────
      # Apariencia
      # ─────────────────────────────────────────

      set -g status-style "bg=#1f2335,fg=#a9b1d6"

      # Ventana activa: amarillo como acento
      set -g window-status-current-style "fg=#e0af68,bold"
      set -g window-status-current-format " #I:#W "

      # Ventanas inactivas
      set -g window-status-style "fg=#565f89"
      set -g window-status-format " #I:#W "

      # Barra izquierda
      set -g status-left "#[fg=#e0af68,bold] #S #[fg=#565f89]│ "

      # Barra derecha
      set -g status-right "#[fg=#7dcfff]%H:%M #[fg=#565f89]│ #[fg=#e0af68]%d-%m "

      set -g status-left-length 30
      set -g status-right-length 50

      # ─────────────────────────────────────────
      # Paneles
      # ─────────────────────────────────────────

      set -g pane-border-style "fg=#3b4261"
      set -g pane-active-border-style "fg=#e0af68"

      # ─────────────────────────────────────────
      # Selección
      # ─────────────────────────────────────────

      set -g mode-style "bg=#e0af68,fg=#1f2335,bold"

      # ─────────────────────────────────────────
      # División de paneles
      # ─────────────────────────────────────────

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      unbind '"'
      unbind %

      # ─────────────────────────────────────────
      # Recargar configuración
      # ─────────────────────────────────────────

      bind r source-file ~/.config/tmux/tmux.conf \; display "Config reloaded!"
    '';
  };
}
