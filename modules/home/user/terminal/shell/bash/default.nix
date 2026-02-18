{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.user.terminal.shell.bash;
  inherit (lib) mkIf optionalAttrs;

  packageNames = map (p: p.pname or p.name or null) config.home.packages;
  hasPackage = name: lib.any (x: x == name) packageNames;
  hasExa = hasPackage "eza";
  hasSpecialisationCli = hasPackage "specialisation";
  hasKitty = config.programs.kitty.enable;

  baseAliases = {
    jqless = "jq -C | less -r";

    n = "nix";
    nd = "nix develop -c $SHELL";
    ns = "nix shell";
    nsn = "nix shell nixpkgs#";
    nb = "nix build";
    nbn = "nix build nixpkgs#";
    nf = "nix flake";

    nr = "nixos-rebuild --flake .";
    nrs = "nixos-rebuild --flake . switch";
    snr = "nixos-rebuild --flake . --use-remote-sudo";
    snrs = "nixos-rebuild --flake . switch --use-remote-sudo";
    hm = "home-manager --flake .";
    hms = "home-manager --flake . switch";

    # Clear screen and scrollback
    clear = "printf '\\033[2J\\033[3J\\033[1;1H'";
  };

  shellAliases =
    baseAliases
    // optionalAttrs hasSpecialisationCli { s = "specialisation"; }
    // optionalAttrs hasExa {
      ls = "eza";
      exa = "eza";
    }
    // optionalAttrs hasKitty {
      cik = "clone-in-kitty --type os-window";
      ck = "clone-in-kitty --type os-window";
    };
in
{
  options.user.terminal.shell.bash = {
    enable = lib.mkEnableOption "Enable Bash";
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      inherit shellAliases;
      initExtra = lib.concatStrings [
        (
          if hasKitty then
            ''
              export KITTY_INSTALLATION_DIR="${pkgs.kitty}/lib/kitty"
              export KITTY_SHELL_INTEGRATION=enabled
              [[ -f "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash" ]] && source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
            ''
          else
            ""
        )
      ];
    };
  };
}
