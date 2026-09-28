{ pkgs, ... }:

pkgs.stdenv.mkDerivation {
  pname = "sddm-haze";
  version = "1.0";

  src = ./sddm-theme-haze;

  installPhase = ''
    mkdir -p $out/share/sddm/themes/haze
    cp -r $src/* $out/share/sddm/themes/haze/
  '';

}
