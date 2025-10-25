{
  inputs,
  pkgs,
  ...
}: {
  theme = {
    wallpaper = inputs.joka00-modules.legacyPackages.${pkgs.system}.wallpapers.astronaut-minimalism.outPath;
    colorscheme.type = "content";
  };
  user = {
    name = "joka-ipa";
    desktop.monitors = [
      {
        name = "eDP-1";
        width = 1920;
        height = 1080;
        primary = true;
        workspace = "1";
      }
    ];
  };
}
