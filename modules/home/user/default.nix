{
  inputs,
  ...
}:
{
  imports = [
    ./core.nix
    ./services
    ./terminal
    ./desktop
    ./theme
    inputs.caelestia-shell.homeManagerModules.default
    inputs.matugen.nixosModules.default
    inputs.nix-index-db.homeModules.nix-index
    inputs.nur.modules.homeManager.default
    inputs.sops-nix.homeManagerModules.sops
  ];
}
