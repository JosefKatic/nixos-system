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
    colorscheme.source = "#717568";
  };
}
