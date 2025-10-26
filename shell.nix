{
  perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = with pkgs; [
          lixPackageSets.stable.lix
          git
          nodePackages.prettier
          sops
          ssh-to-age
          gnupg
          age
          nixd
          nixfmt-rfc-style
          nixfmt-tree
        ];
        name = "config";
        DIRENV_LOG_FORMAT = "";
        shellHook = ''
          ${config.pre-commit.installationScript}
          echo 1>&2 "This is nix shell for JosefKatic/nix-modules"
        '';
      };
    };
}
