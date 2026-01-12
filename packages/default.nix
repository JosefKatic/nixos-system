{
  inputs,
  ...
}:
{
  imports = [ inputs.flake-parts.flakeModules.easyOverlay ];
  perSystem =
    {
      pkgs,
      config,
      ...
    }:
    let
      teamspeak6-server = pkgs.callPackage ./teamspeak6-server { };
      wl-ocr = pkgs.callPackage ./wl-ocr { };
      hdapsd = pkgs.callPackage ./hdapsd { };
      wallpapers = import ./wallpapers { inherit pkgs; };
      allWallpapers = pkgs.linkFarmFromDrvs "wallpapers" (pkgs.lib.attrValues wallpapers);
      # And colorschemes based on it
      generateColorscheme = import ./colorschemes/generator.nix { inherit pkgs; };
      colorschemes = import ./colorschemes { inherit pkgs wallpapers generateColorscheme; };
      allColorschemes = pkgs.linkFarmFromDrvs "colorschemes" (pkgs.lib.attrValues colorschemes);
    in
    {
      overlayAttrs = {
        inherit (config.packages) wl-ocr hdapsd teamspeak6-server;
        inherit (config.legacyPackages)
          wallpapers
          allWallpapers
          generateColorscheme
          colorschemes
          allColorschemes
          ;
      };
      packages = {
        inherit wl-ocr hdapsd teamspeak6-server;
      };
      legacyPackages = {
        inherit
          wallpapers
          allWallpapers
          generateColorscheme
          colorschemes
          allColorschemes
          ;
      };
    };
}
