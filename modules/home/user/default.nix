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
    inputs.matugen.nixosModules.default
    inputs.nix-index-db.homeModules.nix-index
    inputs.nur.modules.homeManager.default
    inputs.sops-nix.homeManagerModules.sops
  ];
}
