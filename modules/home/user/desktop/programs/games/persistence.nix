{
  config,
  lib,
  ...
}:
{
  home.persistence = {
    "/persist" = {
      directories = [
        ".local/share/Steam"
        ".config/lutris"
        ".local/share/lutris"
        "Games"
      ];
    };
  };
}
