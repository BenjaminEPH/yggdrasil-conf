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
  home.sessionPath = [
    "$HOME/.config/emacs/bin"
  ];

  programs.zsh = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/yggdrasil-conf#Yggdrasil";
      ls = "ls --color=auto";
      ll = "ls -lah --color=auto";
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

      format = builtins.concatStringsSep "" [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold blue";
        truncation_length = 3;
        truncation_symbol = "…/";
        read_only = " 󰌾";
        read_only_style = "red";
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold yellow";
        format = "([$all_status$ahead_behind]($style) )";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        modified = "!";
        staged = "+";
        untracked = "?";
        deleted = "✘";
        stashed = "≡";
      };

      nix_shell = {
        symbol = " ";
        style = "bold cyan";
        format = "via [$symbol$state]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bright-black";
        format = "took [$duration]($style) ";
      };
    };
  };
  programs.eza = {
    enable = true;
    enableZshIntegration = true; # define los aliases ls, ll, la, lt...
    icons = "auto";
    git = true; # muestra el estado de git por archivo
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
      emacs

      # misc
      dmidecode

      obsidian

      zig
      zls

      qt6.qtdeclarative
      imagemagick
      gimp

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
  services.emacs = {
    enable = true;
    client.enable = true;
    defaultEditor = true;
    startWithUserSession = true;
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
