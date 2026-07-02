{ config, pkgs, ... }:

{
  home.username = "ben";
  home.homeDirectory = "/home/ben";
  home.stateVersion = "26.05";
  programs.bash = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake ~/yggdrasil-conf#Yggdrasil";
    };
  };
  home.packages = with pkgs; [
    nil
    nixpkgs-fmt
    alacritty
    zoxide
    tmux
  ];
  programs.git = {
    enable = true;
    settings = {
      user.name = "benjamin ely";
      user.email = "benjamin.ely07@gmail.com";
      init.defaultBranch = "main";
    };
  };
}
