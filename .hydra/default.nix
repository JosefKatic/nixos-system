{
  inputs,
  self,
  lib,
  ...
}:
let
  inherit (inputs.nixpkgs) lib;
  notBroken = pkg: !(pkg.meta.broken or false);
  isDistributable = pkg: (pkg.meta.license or { redistributable = true; }).redistributable;
  hasPlatform = sys: pkg: lib.elem sys (pkg.meta.platforms or [ sys ]);
  filterValidPkgs =
    sys: pkgs:
    lib.filterAttrs (
      _: pkg: lib.isDerivation pkg && hasPlatform sys pkg && notBroken pkg && isDistributable pkg
    ) pkgs;
  getConfigTopLevel = _: cfg: cfg.config.system.build.toplevel;
  getActivationPackage = _: cfg: cfg.config.home.activationPackage;
in
{
  flake = {
    hydraJobs = {
      pkgs =
        lib.mapAttrs filterValidPkgs inputs.self.packages
        // lib.mapAttrs filterValidPkgs inputs.self.legacyPackages;
      hosts = lib.mapAttrs getConfigTopLevel self.nixosConfigurations;
      users = lib.mapAttrs getActivationPackage self.homeConfigurations;
    };
  };
}
