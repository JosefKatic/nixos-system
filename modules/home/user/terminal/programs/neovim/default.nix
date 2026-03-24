{
  pkgs,
  ...
}:
{
  programs.nvchad = {
    enable = true;
    extraPackages = with pkgs; [
      nodePackages.bash-language-server
      docker-compose-language-service
      dockerfile-language-server
      lua-language-server
      systemd-language-server
      typescript-language-server
      tailwindcss-language-server
      nixd
      (python3.withPackages (
        ps: with ps; [
          python-lsp-server
          flake8
        ]
      ))
    ];
    hm-activation = true;
    backup = false;
  };
}
