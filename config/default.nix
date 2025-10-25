{
  inputs,
  self,
  ...
}: let
  inherit (inputs) nixpkgs hm systems;
in {
  flake = let
    lib = nixpkgs.lib // hm.lib;
    forEachSystem = f: lib.genAttrs (import systems) (system: f pkgsFor.${system});
    pkgsFor = lib.genAttrs (import systems) (
      system:
        import nixpkgs {
          inherit system;
          overlays = [self.overlays.joka00-modules];
          config = {
            allowUnfree = true;
            allowUnsupportedSystem = true;
          };
        }
    );
    hosts = import "${self}/config/nixos/hosts.nix";
  in {
    nixosConfigurations = let
      specialArgs = {inherit inputs self;};
      inherit (nixpkgs.lib) nixosSystem;
      deviceConfigurations =
        map (host: {
          name = host;
          value = nixosSystem {
            specialArgs = specialArgs;
            modules = let
              hostConfig = import "${self}/config/nixos/${host}/default.nix";
            in [
              {
                networking.hostName = host;
                imports = [
                  self.nixosModules.default
                  hostConfig
                  "${self}/config/nixos/company.nix"
                ];
              }
            ];
          };
        })
        hosts;
    in
      builtins.listToAttrs deviceConfigurations;

    homeConfigurations = let
      inherit (lib) homeManagerConfiguration concatMap;
      configs =
        concatMap (
          host: let
            hostConfig = import "${self}/config/nixos/${host}/static.nix";
          in
            map (user: {
              name = "${user}@${host}";
              value = homeManagerConfiguration {
                modules = [
                  self.homeManagerModules.default
                  "${self}/config/home/${host}/${user}/default.nix"
                ];
                pkgs = pkgsFor.${hostConfig.device.platform};
                extraSpecialArgs = {inherit inputs self;};
              };
            })
            hostConfig.device.home.users
        )
        hosts;
    in
      builtins.listToAttrs configs;
  };
}
