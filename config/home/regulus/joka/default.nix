{
  pkgs,
  inputs,
  ...
}: {
  user = {
    name = "joka";
    terminal = {
      shell.fish.enable = true;
    };
  };
  theme = rec {
  };
}
