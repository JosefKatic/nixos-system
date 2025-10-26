{
  pkgs,
  inputs,
  ...
}:
{
  user = {
    name = "joka";
  };
  theme = rec {
    colorscheme.source = "#BC9A55";
  };
}
