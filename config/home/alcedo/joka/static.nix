{
  pkgs,
  inputs,
  ...
}: {
  theme = rec {
    wallpaper = inputs.joka00-modules.legacyPackages.${pkgs.system}.wallpapers.binary-black-8k.outPath;
    colorscheme.type = "monochrome";
  };
  user = {
    name = "joka";
    desktop.monitors = [
      {
        name = "DP-1";
        width = 2560;
        height = 1440;
        primary = true;
        position = "auto-left";
        workspace = "1";
      }
      {
        name = "DP-2";
        width = 2560;
        height = 1440;
        workspace = "11";
      }
    ];
  };
}
