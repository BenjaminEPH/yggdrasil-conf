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
  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/yggdrasil-conf#Yggdrasil";
    };
    plugins = [
      {
        name = "tide";
        src = pkgs.fishPlugins.tide.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "grc";
        src = pkgs.fishPlugins.grc.src;
      }
    ];
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
    enableFishIntegration = true;
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
